---@class SettlementControl:OOControlBase
---@field m_model SettlementModel
local M = class("SettlementControl", LikeOO.OOControlBase)

function M:onEnter()
    self:setOnceTimer(
        0.1,
        function()
            self:closeView("GamePanel")
            self:closeView("GamePanel.GamePanelPop")
        end
    )
    self.m_guide_file_name = "UI.Settlement.Guide"
    self.get_new_hero = false
    TimeManager_View:set_timeScale(GlobalTools.base1)
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:HidePlane(false)
    end

    if (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE) and self.m_model.m_data.fail_times then
        local stage_tab = ConfigManager:getCfgByName("stage")
        local curLevel = UserDataManager:getBattleStage()
        local data = stage_tab[curLevel]
        if data and data.mercenary and data.mercenary > 0 then
            if self.m_model.m_data.fail_times == data.mercenary then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0610"), delay_close = 2})
            end
        end
    elseif (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) and self.m_model.m_data.fail_times then
        local stage_tab = ConfigManager:getCfgByName("stage")
        local curLevel = UserDataManager:getBattleStage()
        local data = stage_tab[curLevel]
        if data and data.mercenary and data.mercenary > 0 then
            if self.m_model.m_data.fail_times == data.mercenary then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0610"), delay_close = 2})
            end
        end
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.BIOGRAPHY then
        local data = {}
        data.bio_data = table.copy(self.m_model.m_data.bio_data)
        data.bio_done = table.copy(self.m_model.m_data.bio_done)
        self:updateMsg("update_data", data, "Biography")
        self:updateMsg("update_data", data, "Biography.BiographyChapter")
    end
    --self:clearAsset()
    self.time = self:setTimer(1, handler(self, self.updateTime))
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE and self.m_model.m_data.update and self.m_model.m_data.update == 1 then
        self:closeView("GamePanel")
        self:closeView("Activities.WorldBoss")
        self:updateMsg("update_data", self.m_model.m_data, "Activities.WorldBoss.HeroBossTrainPop")
        self:closeView()
    end
end

function M:clearAsset( unloadFinish )
    if self.m_model.m_result == 1 then -- 推图胜利时清理资源完成后加载英雄
        local mode = self.m_model.m_mode
        ResourceUtil:AddUnLoadFinish(
                function()
                    if self.m_model and (mode == GlobalConfig.BATTLE_MODE.STAGE or mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT)  then
                        SceneManager:getCurSceneView():preLoadBattleStageHero()
                    end
                    if unloadFinish ~= nil then
                        unloadFinish()
                    end
                end
        )
        if mode == GlobalConfig.BATTLE_MODE.STAGE or mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
            SceneManager:getCurSceneView():checkUnLoadBundle(2, mode)
        else
            SceneManager:getCurSceneView():checkUnLoadBundle(3, mode)
        end
    end
end

function M:startGuide()
end

function M:onHandle(msg, data)
    local function _antiAddiction_endBattle(end_todo_cb)
        SDKUtil:antiAddiction(
            0,
            function(rst)
                if rst then
                    end_todo_cb()
                else
                    SDKUtil:logOut(
                        function()
                            GameMain.reStart()
                        end
                    )
                end
            end
        )
    end

    local mode = self.m_model.m_mode
    local model = self.m_model
    if msg == 99999 then -- 返回
        --audio:SendEvtBGM('play_hangup_bgm',true)
        self.m_view:showOverWord()
        _antiAddiction_endBattle(
            function()
                self:closeView("GamePanel")
                model.is_new_open_func = data and data.is_new_open_func
                self:goToMain(mode, model, 1)
            end
        )
    elseif msg == "win_cancle_btn" or msg == "lost_cancle_btn" then
        self:goToMain(mode, model)
    elseif msg == "adjust_btn" then --调整阵容
        self:okGoToFormation(
            mode,
            model,
            function()
                self:closeView()
            end
        )
    elseif
        msg == "intensify_btn" or msg == "hero_level_up_btn" or msg == "wear_equip_btn" or msg == "strengthen_equip_btn"
     then --强化装备
        --self:goToMain(mode,model)
        SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
        self:closeView()
        self:closeAllViewPop()
        QuickOpenFuncUtil:openFunc(5)
    elseif msg == "no_open_btn" then --未开启
    elseif msg == "win_ok_btn" then -- --下一关
        _antiAddiction_endBattle(
            function()
                if mode == GlobalConfig.BATTLE_MODE.TOWER or mode == GlobalConfig.BATTLE_MODE.RACE_TOWER or mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then
                    self:goToFormation(
                        mode,
                        model,
                        function()
                            self:closeView()
                            StateSoundManager:playBGM(mode)
                        end,
                        true
                    )
                else
                    local stage_cfg = GameUtil:getBattleStageCfg()
                    local skip_deploy = stage_cfg.skip_deploy or 0
                    if skip_deploy == 0 then
                        self:goToFormation(
                            mode,
                            model,
                            function()
                                self:closeView()
                                StateSoundManager:playBGM(mode)
                            end,
                            true
                        )
                    else
                        self:updateMsg(99999)
                    end
                end
            end
        )
    elseif msg == "lost_ok_btn" or msg == "lost_ok_btn2" then -- 再次挑战
        _antiAddiction_endBattle(
            function()
                if mode == GlobalConfig.BATTLE_MODE.TOWER or mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then
                    self:okGoToFormation(
                        mode,
                        model,
                        function()
                            self:closeView()
                            StateSoundManager:playBGM(mode)
                        end
                    )
                else
                    local stage_cfg = GameUtil:getBattleStageCfg()
                    local skip_deploy = stage_cfg.skip_deploy or 0
                    if skip_deploy == 0 then
                        self:okGoToFormation(
                            mode,
                            model,
                            function()
                                self:closeView()
                                StateSoundManager:playBGM(mode)
                            end
                        )
                    else
                        self:updateMsg(99999)
                    end
                end
            end
        )
    elseif msg == "win_record_btn" or msg == "lost_record_btn" then
        if self.m_model.auotChapterBl == 1 then --查看输出默认关闭自动勾选状态
            self.m_model.auotChapterBl = 0
            self.m_view:refreshUI()
        end
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE then -- 迷宫
            self:updateMsg("update_data", {data = self.m_model.m_data}, "MazeStage")
        elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then --古剑奇谭
            self:updateMsg("update_data", {data = self.m_model.m_data}, "GuJianQiTan.GuJianQiTanMaze")
        end

        self:closeView("Pops.BattleStatistics")
        self:openView("Pops.BattleStatistics", {data = self.m_model.m_data, round = self.m_model.m_params.round or 1, mode = self.m_model.m_mode, budo_floor = self.m_model.m_budo_floor})
    elseif msg == "battle_log_btn" then
        self:closeView("Pops.BattleStatistics")
        self:openView(
            "Pops.BattleStatistics",
            {data = self.m_model.m_data, round = data.index, mode = self.m_model.m_mode}
        )
    elseif msg == "check_chapter_unlock" then
        self:checkChapterUnlock()
    elseif msg == "return_btn" then
        self:updateMsg(99999)
    elseif msg == "auto_next" then
        if self.m_model.auto_open_limit == true then
            local can_click, str = self.m_model:checkChapterNextLimit()
            if can_click == 3 then
                if self.m_model.auotChapterBl == 1 then
                    self.m_model.auotChapterBl = 0
                    self.m_model.autoChapterDownTime = 5
                    self:updateTime()
                else
                    self.m_model.autoChapterDownTime = 5
                    self.m_model.auotChapterBl = 1
                    self:updateTime()
                end
                self.m_view:refreshUI()
            elseif can_click == 2 and str then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("xian_str_0010", str), delay_close = 2})
            elseif can_click == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("xian_str_0009"), delay_close = 2})
            end
        end
    elseif msg == "btn_retain" then -- 公会战-模拟挑战保存战绩
        self:gvgSaveMock()
    elseif msg == "btn_return" then -- 公会战-返回
        --self:updateMsg(99999)
        self:closeView("Settlement")
    elseif msg == "img_btn_mask" then --战败返回
        self:closeView("Settlement")
    elseif msg == "replay_btn" then
        self:replayBattle()

    elseif msg=="rta_over_btn" then--剑出红蒙
        self:updateMsg(99999)
    end
end

function M:replayBattle()
    self:openView("GamePanel", {data = self.m_model.m_data, mode = self.m_model.m_data.battle.sort, replay = true, })
    self:closeView()
end

function M:returnFormation()
    
end

function M:gvgSaveMock()
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward, nil ,function()
            if self.m_model then
                self:updateMsg(99999)
                self:closeView("Formation")
            end
        end)
    end
    self.m_model:getNetData("gvg_save_mock", {}, netCallback)
end

function M:goToFormation(mode, model, func, auto_battle_flag)
    self.m_view:showOverWord();
    self.m_view:lockTouch()
    self:setOnceTimer(
        0,
        function()
            ResourceUtil:AddUnLoadFinish(function()
                self.m_view:unlockTouch()
                if mode == GlobalConfig.BATTLE_MODE.STAGE or mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
                    SceneManager:getCurSceneView():preLoadBattleStageHero()
                end
                self:okGoToFormation(mode, model, func, auto_battle_flag)
            end)
            if mode == GlobalConfig.BATTLE_MODE.STAGE or mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
                SceneManager:getCurSceneView():checkUnLoadBundle(2, mode);
            else
                SceneManager:getCurSceneView():checkUnLoadBundle(3, mode);
            end
        end
    )
end

function M:okGoToFormation(mode, model, func, auto_battle_flag)
    local mode_util_item = BattleModeUtil[mode]
    if mode_util_item and mode_util_item.settlementControlToFormation then
        mode_util_item.settlementControlToFormation(self, mode, model, func, auto_battle_flag)
    else
        --     end
        --  end })
        --   self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
        --      if open_flag == "open_view" then
        self:openView("Pops.TransitionPage", {open_view_name = "Formation" ,open_view_params = {mode = mode, enter_call_func = func, def_data = model.m_def_data, new_chapter = self.m_new_chapter}})

        -- self:openView(
        --     "Formation",
        --     {mode = mode, enter_call_func = func, def_data = model.m_def_data, new_chapter = self.m_new_chapter}
        -- )
        self:showNewHero(model)
        if #self.m_new_heros > 0 then
            EventDispatcher:dipatchEvent("show_new_hero", self.m_new_heros)
        end
    end
    self:closeView()
end

function M:goToMain(mode, model, type)
    --self.m_view:showOverWord();
    type = type or 0
    if self.m_view then
        self.m_view:lockTouch()
    end
    self:setOnceTimer(
        0,
        function()
            ResourceUtil:AddUnLoadFinish(function()
                if self.m_view then
                    self.m_view:unlockTouch()
                end
                local mode_util_item = BattleModeUtil[mode]
                if mode_util_item and mode_util_item.settlementControlClose then
                    mode_util_item.settlementControlClose(self, mode, model, type)
                else
                    if self.m_model:checIsSkip() == true then
                        self:updateMsg("battle_end_refresh_ui", nil, "Formation")
                        self:closeView()
                        return
                    end
                    self:showNewHero()
                    -- if self.m_new_chapter then
                    --     local params = {}
                    --     params.new_heros = self.m_new_heros
                    --     self:openView("Pops.PlotPop", params)
                    -- else
                    if #self.m_new_heros > 0 then
                        EventDispatcher:dipatchEvent("show_new_hero", self.m_new_heros)
                    else
                        self:updateMsg("checkLvUp", nil, "parent")
                        self:updateMsg("show_a_xian_tips", nil, "parent")
                        self:updateMsg("common_refresh", nil, "parent")
                    end
                    -- end
                    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
                        self:updateMsg("refresh_sence", nil, "PetBreeding.PetBreedingMain")
                    else
                        SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
                    end
                end
    
                if type == 1 then
                    if mode ~= GlobalConfig.BATTLE_MODE.FIVE_ARRAY and mode ~= GlobalConfig.BATTLE_MODE.BIG_MAP and 
                            mode ~= GlobalConfig.BATTLE_MODE.EVIL_SHADOW and mode ~= GlobalConfig.BATTLE_MODE.DRAGONSWORD
                            and mode ~= GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS
                            and mode ~= GlobalConfig.BATTLE_MODE.COMMON_BATTLE
                            and mode ~= GlobalConfig.BATTLE_MODE.NEW_BIG_MAP then
                        self:closeView()
                    end
                else
                    self:closeView()
                end
                if  model.is_new_open_func then
                    EventDispatcher:registerTimeEvent("delay_close_loading_time",function()
                        static_rootControl:updateMsg("close_sync_load_big_loading");
                    end,0.1,0.1)
                end
            end)
            if mode == GlobalConfig.BATTLE_MODE.STAGE or mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
                SceneManager:getCurSceneView():checkUnLoadBundle(1, mode);
            else
                SceneManager:getCurSceneView():checkUnLoadBundle(3, mode, {boss_id = model.m_boss_id});
            end
        end
    )
end

--下一章
function M:playNextChapter()
    --self:openView("Pops.PlotPop", { callback = function()
        if self.m_model then
            self:chapterUnlock()
            self:updateMsg("show_new_chapter_verse", nil, "parent")
            if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE then
                self:updateMsg("win_ok_btn")--继续战斗
            else
                self:goToMain(self.m_model.m_mode, self.m_model, 1)--返回主界面
            end
        end
    --end })
end

--返回主界面
function M:playGotoMain()
    if self.m_model then
        self:chapterUnlock()
        self:updateMsg("show_new_chapter_verse", nil, "parent")
        --返回主界面
        self:goToMain(self.m_model.m_mode, self.m_model, 1)
    end
end

function M:checkChapterUnlock()
    if self.m_model:getIsNewChapter() then
        local function netCallBack()
            local chapter_over_rewards, quest_id = self.m_model:getChapterOverRewards()
            if #chapter_over_rewards > 0 and quest_id then
                local function callback()
                    self:playGotoMain()
                end
                local function callbackNext()
                    self:playNextChapter()
                end
                self:openView(
                        "Pops.CommonTaskRewardPop",
                        {quest_id = quest_id, main_quest = chapter_over_rewards, callback = callback, callbackNext = callbackNext, show_next_chapter = true},
                        nil,
                        true
                )
            else
                self:playGotoMain()
                --self:playNextChapter()
            end
        end
        self.m_model:getNetData("chapter_unlock", nil, netCallBack, nil, nil, nil, {forceBack = true })
    else
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE then
            if self.m_model.m_result == 0 then
                local id = ConfigManager:getCommonValueById(279) -- 第一次战斗失败 挂机奖励引导
                if UserDataManager.guide_data:setAnyTeamGuide(id) == false then
                    local data = ConfigManager:getCommonValueById(312) -- 第二次战斗失败装备强化引导
                    local stage_id = UserDataManager:getBattleStage()
                    if stage_id >= data[1] then
                        local team = UserDataManager.hero_data:getTeamByKey("stage")
                        local has_guide = false
                        for k, v in pairs(team) do
                            if v ~= "" then
                                local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
                                if hero then
                                    for kk, vv in pairs(hero.equips) do
                                        local equ_cfg = UserDataManager.equip_data:getEquipConfigByCid(vv.id)
                                        if equ_cfg.quality > 2 and vv.lv == 0 then
                                            has_guide = true
                                            break
                                        end
                                    end
                                end
                            end
                            if has_guide then
                                break
                            end
                        end
                        if has_guide then
                            UserDataManager.guide_data:setAnyTeamGuide(data[2])
                        end
                    end
                    --第三次推图失败
                    local guideServer = UserDataManager:getGuide()
                    local server = guideServer[tostring(data[2])]
                    if server then --已经引导过第二次推图失败
                        local third_id = ConfigManager:getCommonValueById(291)
                        UserDataManager.guide_data:setAnyTeamGuide(third_id)
                    end
                end
            else
                if self.m_model.m_data.new_chapter ~= nil then
                    self.m_new_chapter = self.m_model.m_data.new_chapter
                end
            end
        end
    end
end

function M:chapterUnlock()
    self.m_new_chapter = true
    self.m_model.m_data.new_chapter = true
    --self.m_guide:checkGuide()
    --self.m_view:guideVisible()
end

function M:showNewHero(model)
    model = model or self.m_model
    local data = model.m_rewards or {}
    local heros = {}
    for i, v in ipairs(data) do
        if v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS then
            if UserDataManager.hero_data:isNewHero(v[2]) then
                table.insert(heros, v)
            end
        end
    end
    self.m_new_heros = heros
end

function M:updateTime()
    if self.m_model.autoChapterNextOpen == true and self:can3DTouchByViewName("Settlement") then
        if self.m_model.auotChapterBl == 1 and self.m_model.autoChapterDownTime <= 0 and self.m_model.auto_open_limit == true then
            self:updateMsg("win_ok_btn")
            self.m_model.autoChapterNextOpen = false
        else
            self.m_view:refreshUI()
        end
        self.m_view:updateTime()
        self.m_model.autoChapterDownTime = self.m_model.autoChapterDownTime - 1
    end
end

function M:destroy()
    if self.time then
        self:removeTimer(self.time)
    end
    UserDataManager.local_data:setUserDataByKey("auot_chapter_bl", self.m_model.auotChapterBl)
    M.super.destroy(self)
end

return M
