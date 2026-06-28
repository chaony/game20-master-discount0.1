local M = class("GuJianQiTanMazeControl",LikeOO.OOControlBase)

function M:onEnter()
    --SceneManager:setData("show_loading_black", true)
    self:mazeInitialTier()
    if SceneManager.curScene.sceneId == SceneManager.SceneID.GuJianQiTanScene then
        SceneManager.curScene:resetSceneData( self.m_model )
        local scene_view = SceneManager:getCurSceneView()
        if scene_view then
            scene_view:setBGMusic()
        end
    else
        SceneManager:changeScene(SceneManager.SceneID.GuJianQiTanScene,self.m_model)
        SceneManager:scenestart()
    end
    self.m_next_enter_lock = false
    self.m_guide_file_name = "UI.GuJianQiTan.GuJianQiTanMaze.Guide"
    self.clickCount = 0;
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
end

-- 选择初始层
function M:mazeInitialTier(data, param)
    --local cell_type = data.type
    local function netCallback(response)
       -- self.m_model:initData(response)
    end
    local params = {floor = 0, mver = self.m_model.m_data.mver}
    --self.m_model:getNetData("maze_choose_floor", params, netCallback)
    --打开遗物界面
    if self.m_model.m_data.recv_heirloom ~= nil and _G.next(self.m_model.m_data.recv_heirloom) then
        local m_data = {}
        m_data.heirloom_pool = self.m_model.m_data.recv_heirloom;
        --弹选择遗物
        self:openView("MazeStage.MazeStageRelicSelect", { data = m_data, show_tips = false})
    end
end

function M:startGuide()

end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView("Guide.GuideDialog")
        --self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
        --    if open_flag == "open_view" then
        --        SceneManager:setData("show_loading_black", true)
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
                SceneManager:getCurSceneModel():stopScene();
                self:closeView()
        --        if not self:hasChild("Main.Outskirts") then
        --            self:updateMsg("close_battle_loading", nil, "parent")
        --        end
        --    end
        --end })
    elseif msg == "help_btn" then --帮助说明
        local params = {}
        params.title = "gu_jian_qi_tan_str_003"
        params.content = "tid#SwordDes2"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 18})
    elseif msg == "hero_btn" then -- 武魂
        self:openView("GuJianQiTan.GuJianQiTanMazeHeros", {data = self.m_model.m_data, death_hero_oids = self.m_model:getDeathHeroOids()})
    elseif msg == "relic_btn" then -- 遗物
        self:openView("MazeStage.MazeStageRelic", {data = self.m_model.m_data})
    elseif msg == "shop_btn" then --商铺
        self:openView("Shop", {shop_type = 4, pop_from_func_id = -1})
        --QuickOpenFuncUtil:openFunc(15)
    elseif msg == "explain_btn" then --说明
        self:openView("Pops.CommonHelpPop", { title = "tid#maze_text2", content = "tid#maze_text1" })
    elseif msg == "cell_click" then
        self:openCellPop(data.data, data.clickCallBack)
    elseif msg == "maze_goto" then
        local path_data = data.data
        if data.data == nil then
            path_data = data
        end
        self:mazeGoto(path_data)
    elseif msg == "box_click" then
        local status = data.data.status
        if status == 0 then
            local rewards = data.data.rewards or {}
            self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
        elseif status == 2 then
            self:recvExploreReward(data.data.id)
        end
    elseif msg == "maze_employ" then
        self:mazeEmploy(data)
    elseif msg == "maze_bless" then
        self:mazeBless(data)
    elseif msg == "maze_melt" then
        self:mazeMelt(data)
    elseif msg == "refresh" then
        self:closeAllViewPop({ ["Loading.SyncLoadBigLoading"] = 1, ["GuJianQiTan.GuJianQiTanMain"] = 1  });
    elseif msg == "maze_revive_all" then
        self:mazeReviveAll()
    elseif msg == "maze_add_blood" then
        self:mazeAddBlood(data)
    elseif msg == "upAllCells" then
        local params = {}
        --params.option_event = data.event_id;
        params.mver = self.m_model.m_data.mver
        params.version = self.m_model.m_version
        params.cur_round = self.m_model.m_cur_round
        self.m_model:getNetData("ancient_sword_and_wonderland_set_all_passed",params, function( response )
            if self:responseExpirtCheck(response) == false then
                return
            end
            if data.setPassed ~= nil then
                data:setPassed( self.m_model.m_data.passed )
            end
        end)    
    elseif msg == "maze_move_grid" then
        --更新位置
        self.m_view:move_grid(data)
    elseif msg == "maze_show_grid" then
        --显示格子
        self.m_view:maze_show_grid( data )
    elseif msg == "set_grid_position" then
        self.m_view:set_grid_position( data )
    elseif msg == "maze_clear_grid" then
        self.m_view:clear_grid()
    elseif msg == "load_finish" then
        self.m_guide:checkGuide()
    elseif msg == "maze_chioce_option" then
        local function netCallback(response)
            if self:responseExpirtCheck(response) == false then
                return
            end
            if response then
                RewardUtil:rewardTipsByData(response.reward, nil, nil,{allDouble = self.m_model.doubleReward})
                TimeTools:delayTimeUnity(1,function()
                    if SceneManager.curScene.resetClickRoom ~= nil then
                        SceneManager.curScene:resetClickRoom();
                    end
                end)
                if self.m_view then
                    self.m_view:refreshUI()
                    SceneManager.curScene:handlerFinish();
                end
            end
        end
        local params = {}
        params.option_event = data.option_id;
        params.cell_id = data.id;
        params.mver = self.m_model.m_data.version
        params.version = self.m_model.m_version
        params.cur_round = self.m_model.m_cur_round
        self.m_model:getNetData("ancient_sword_and_wonderland_encounter_choice_option", params, netCallback, nil,nil,GlobalConfig.POST)
    elseif msg == "maze_battle_start" then -- 战斗开始
        self:goBattle(data)
    elseif msg == "show_no_move_messag" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0881"), delay_close = 2})
    elseif msg == "my_count" then --
        --self.count_tips
        self.clickCount = self.clickCount + 1;
        if self.clickCount % 2 == 0 then
            self.m_view.count_tips:SetActive(false)
        else
            self.m_view.count_tips:SetActive(true)
        end
    elseif msg == "maze_revive_one" then
        self:mazeReviveOne(data)
    elseif msg == "goto_battle" then
        --点击确定之后，移动，移动完成再进入战斗
        SceneManager.curScene:clickSure(data.data.type, function()
            SceneManager.curScene:handlerFinish()
            --self:closeView("MazeStage.MazeStageDetail")
            SceneManager.lastScene = SceneManager.SceneID.GuJianQiTanScene;
           -- self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
              --  if open_flag == "open_view" then
            if self.m_model ~= nil then
                self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE, def_data = data.data, death_hero_oids = self.m_model:getDeathHeroOids(), assist_heros = self.m_model.m_data.assist_heros, heirlooms = self.m_model.m_data.heirlooms, dyns = self.m_model.m_data.dyns})
                UserDataManager:setTempData("gu_jian_maze_battle_type", data.data.type)
            end
             --   end
           -- end })
        end)
    elseif msg =="maze_select_heirloom" then
        self:mazeSelectHeirloom(data)
    elseif msg == "battle_end_refresh_ui" then
        local path_data = data.data
        self.m_model:netData(data.data)
        if data.open_formation == 1 then -- 战斗失败去布阵
            if self.m_model.m_select_id then
                local new_data = self.m_model:getMazeCellDataById(self.m_model.m_select_id, true)
                self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE, type = data.data.m_type, death_hero_oids = self.m_model:getDeathHeroOids(),def_data = new_data, assist_heros = self.m_model.m_data.assist_heros, heirlooms = self.m_model.m_data.heirlooms, dyns = self.m_model.m_data.dyns, enter_call_func = data.func})
            end
        else
            if data.func then
                data.func()
            end
            self.m_model.start = false
            SceneManager:changeScene(SceneManager.SceneID.GuJianQiTanScene, self.m_model)
            SceneManager.curScene:handlerFinish();
            --self:updateMsg("maze_goto",{data = data.data,param = data.param})
            self.m_view:refreshUI()
            if path_data.add_heirloom ~= nil and _G.next(path_data.add_heirloom) then
                local m_data = {}
                m_data.heirlooms  = path_data.add_heirloom;
                --弹选择遗物
                self:openView("Pops.RelicReward", m_data)
                --self:openView("MazeStage.MazeStageRelicSelect", { data = m_data, show_tips = false})
            end
            
            --if self.m_model.m_select_id then
            --    local new_data = self.m_model:getMazeCellDataById(self.m_model.m_select_id, true)
            --    if new_data.status == 2 then
            --        self:openView("MazeStage.MazeStageRelicSelect", {data = new_data, show_tips = false})
            --    end
            --end
        end
    elseif msg == "change_scene" then
        SceneManager:changeScene(SceneManager.SceneID.GuJianQiTanScene,self.m_model)
    elseif msg == "box_btn" then
        self:mazeRecvReward()
    elseif msg == "next_btn" then
        self:mazeEnterNext()
    elseif msg == "floor_reward_btn" then
        self:openView("GuJianQiTan.GuJianQiTanMazeReward", {version = self.m_model.m_data.version})
    elseif msg == "bless_btn" then
        local content_data = self.m_model:getBlessData()
        if content_data and next(content_data) then
            self:openView("GuJianQiTan.GuJianQiTanMazeContentPop", {content_data = content_data})
        end
    elseif msg == "maze_give_up" then
        self:mazeGiveUp()
    elseif msg == "speed_btttle" then
        self:speedBattle(data)
    elseif msg == "maze_buy" then
        self:mazeBuy(data)   
    elseif msg == "after_open_cellPop" then
        -- self:afterOpenCellPop(data.data);
    elseif msg == "relic_formation_btn" then
        self:openView("MazeStage.MazeStageRelicFormationShow", {data = self.m_model.m_data})
    elseif msg == "guide_check" then
        self.m_guide:checkGuide()
    elseif msg == "update_data" then
        self.m_model:netData(data.data)
    elseif msg == "sendOpenDoorMessage" then
        self:sendOpenDoorNet( data );
    elseif msg == "reward_maze_heirloom_anim" then
        local cache_nodes = data.cache_nodes or {}
        for k,v in pairs(cache_nodes) do
            self:runHeirloomAnim(v.cell_object, v.id)
        end
        if data.close_call then
            data.close_call()
        end
    elseif msg == "lock_box_without_key_tips" then
        self:lockBoxWithoutKeyTips()    
    end
end


function M:speedBattle( data )
    local function setCallback(response)
        --点击快速战斗
        --战斗内删除物体
        self.m_model:netData(response)
        self.m_view:refreshUI()
        if response.need_battle ~= nil and response.need_battle == 1 then
            self:updateMsg("goto_battle", {data = data.m_cell_data})
        else
            SceneManager.curScene:clickSure(1, function()
                SceneManager.curScene:playerAttack();
                self:setOnceTimer(0.8, function()
                    SceneManager.curScene:handlerFinish()
                    SceneManager.curScene.isInMoving = false;
                end)
            end)
        end
    end
    local params = {}
    params.cell_id = data.m_cell_id;
    params.mver = data.m_mver;
    --快速战斗
    --self.m_model:getNetData("maze_auto_battle",params, setCallback, nil, nil, GlobalConfig.POST)
    --取消
end


function M:recvExploreReward( level )
    local function netCallback(response)
        if self.m_view then
            self.m_model:netData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local params = { level = level, mver = self.m_model.m_data.mver}
    --self.m_model:getNetData("maze_recv_explore_reward", params, netCallback)
    --取消
end


function M:goBattle(data)
    UserDataManager:setTempData("maze_battle_event_id", data.event_id)
    local encounter_cfg = ConfigManager:getCfgByName("maze_encounter")
    local encounter_cfg_item = encounter_cfg[data.event_id] or {}
    local battle_id = encounter_cfg_item.event_battle or 0
    if battle_id > 0 then
        --关闭奇遇
        self:openView("Formation", {battle_id = battle_id, def_data = data.cell_data, type = "maze_encounter_battle_start", death_hero_oids = self.m_model:getDeathHeroOids(), mode = GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE, assist_heros = self.m_model.m_data.assist_heros, heirlooms = self.m_model.m_data.heirlooms, dyns = self.m_model.m_data.dyns})
    end
end

--点击回调
function M:openCellPop(data, clickCallBack)
    --1.小怪 2.精英 3.boss 4.客栈 5.医馆 6.药王庙 7.商铺 8.空格 9.起点 10.怨灵马车 11.宝藏洞窟 12 奇遇事件 14 地面宝箱 16 宝箱
    local cell_type = data.type
    local open_flag = true --self.m_model:getMazeCellIsOpen(data.id, true)
    self.m_model.m_select_id = data.id
    if cell_type == 1 or cell_type == 2 or cell_type == 3 then
        --进入下一层正在执行，不允许点击小怪
        if self.m_next_enter_lock == true then
            if SceneManager.curScene.resetClickRoom ~= nil then
                SceneManager.curScene:resetClickRoom();
            end
            return
        end
        if data.status == 2 then
            self:openView("GuJianQiTan.GuJianQiTanMazeRelicSelect", {data = data})
        else
            self:openView("GuJianQiTan.GuJianQiTanMazeBattle", {data = data, mver = self.m_model.m_data.mver, version = self.m_model.m_version,
                                                                cell_id = data.id,
                                                                heros_combat = self.m_model.heros_combat,
                                                                cur_floor = self.m_model.m_data.floor_id,
                                                                max_floor= self.m_model.m_data.max_floor,
                                                                open_flag = open_flag, callBack = clickCallBack})
        end
    elseif cell_type == 4 then
        --选择雇佣英雄
        local function localClickCallBack( moveFinish )
            if moveFinish.select_index == nil or moveFinish.select_index == -1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0357"), delay_close = 2})
                if SceneManager.curScene.resetClickRoom ~= nil then
                    SceneManager.curScene:resetClickRoom();
                end
                return
            end
            if clickCallBack ~= nil then
                clickCallBack( moveFinish );
            end
        end
        self:openView("GuJianQiTan.GuJianQiTanMazeHeroSelect", {data = data, open_flag = open_flag, callBack = localClickCallBack, assist_heros = self.m_model.m_data.assist_heros})
    elseif cell_type == 5 or cell_type == 6 then
        --回血
        self:openView("GuJianQiTan.GuJianQiTanMazeHospital", {data = data, open_flag = open_flag, callBack = clickCallBack})
    elseif cell_type == 7 then
        --商店
        self:openView("GuJianQiTan.GuJianQiTanMazeShop", {data = data, open_flag = open_flag, callBack = clickCallBack, mver = self.m_model.m_data.mver})
    elseif cell_type == 10 or cell_type == 11 then
        self.m_model.m_select_id = data.id
        self:openView("GuJianQiTan.GuJianQiTanMazeAncestor", {data = data, open_flag = open_flag, callBack = clickCallBack})
    elseif cell_type == 14 then
        --地面宝箱
        --local params = {
        --    on_ok_call = function(msg)
        --        
        --    end,
        --    on_cancel_call = function(msg)
        --        
        --    end,
        --    no_close_btn = false,
        --    tow_close_btn = true,
        --    text = Language:getTextByKey("new_str_0615")
        --}
        --static_rootControl:openView("Pops.CommonPop", params)

        local function netCallback(response)
            if self:responseExpirtCheck(response) == false then
                return
            end
            if self.m_view and response then
                self.m_model:netData(response)
                self.m_view:refreshUI()
                self.m_view:showLevelEffect();
                SceneManager.curScene:handlerFinish();
                RewardUtil:rewardTipsByData(response.reward, nil, function()
                    --local floor_ids = self.m_model:getNextFloorIds()
                    --local floor_id = floor_ids[1]
                    --if floor_id == nil then
                    -- self:openView("MazeStage.MazeStageBattleOver", {data = self.m_model.m_data})
                    --end
                    --弹结算
                end,{allDouble = self.m_model.doubleReward})
            else
                if SceneManager.curScene.resetClickRoom ~= nil then
                    SceneManager.curScene:resetClickRoom();
                end
            end
        end
        local params = {}
        params.mver = self.m_model.m_data.mver
        params.cell_id = data.id
        params.version = self.m_model.m_version
        params.cur_round = self.m_model.m_cur_round
        self.m_model:getNetData("ancient_sword_and_wonderland_recv_reward", params, netCallback, nil, true)
        audio:SendEvtUI("UI_TresureChest_Open1")
    elseif cell_type == 16 then--宝箱
        self:requestForRewardBox(data)
    elseif cell_type == 12 then
        --奇遇事件
        if _G.next(data.encounter) ~= nil then
            local event_data = ConfigManager:getCfgByName("sword_akuma_event")
            local sample_data = event_data[data.encounter.event_id];
            local event_id = data.encounter.event_id
            static_rootControl:openView("GuJianQiTan.GuJianQiTanMazeEncounterDetail", {event_data = sample_data, cell_id = data.id, cell_data = data, event_id = event_id})
        end
    elseif cell_type == 13 then  --出口
        local params = {
            on_ok_call = function(msg)
                local moveBackdata = {
                    callback = function()
                        self:updateMsg("sendOpenDoorMessage", { cell_type = cell_type })
                    end
                }
                if SceneManager.curScene.resetClickRoom ~= nil then
                    SceneManager.curScene:resetClickRoom();
                end
                if clickCallBack ~= nil then
                    clickCallBack( moveBackdata );
                end
            end,
            on_cancel_call = function(msg)
                if SceneManager.curScene.resetClickRoom ~= nil then
                    SceneManager.curScene:resetClickRoom();
                end
            end,
            no_close_btn = false,
            tow_close_btn = true,
            text = Language:getTextByKey("new_str_0616")
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif cell_type == 21 then --上锁宝箱
        self:requestForRewardBox(data)
    elseif cell_type == 22 then --钥匙钱袋
        --local params = {
        --    on_ok_call = function(msg)
        --        
        --    end,
        --    on_cancel_call = function(msg)
        --        
        --    end,
        --    no_close_btn = false,
        --    tow_close_btn = true,
        --    text = Language:getTextByKey("new_str_0615")
        --}
        --static_rootControl:openView("Pops.CommonPop", params)
        --self:updateMsg("maze_goto_guide")
        local function netCallback(response)
            if self:responseExpirtCheck(response) == false then
                return
            end
            if self.m_view and response then
                self.m_model:netData(response)
                self.m_view:refreshUI()
                self.m_view:showLevelEffect();
                SceneManager.curScene:handlerFinish();
                RewardUtil:rewardTipsByData(response.reward, nil, function()
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_049"), delay_close = 2})
                    --local floor_ids = self.m_model:getNextFloorIds()
                    --local floor_id = floor_ids[1]
                    if UserDataManager.guide_data:isGuiding() then
                        self:updateMsg("guide_check")
                    end
                    --if floor_id == nil then
                    -- self:openView("MazeStage.MazeStageBattleOver", {data = self.m_model.m_data})
                    --end
                    --弹结算
                end, {allDouble = self.m_model.doubleReward})
            else
                if SceneManager.curScene.resetClickRoom ~= nil then
                    SceneManager.curScene:resetClickRoom();
                end
            end
        end
        local params = {cell_id = data.id,mver = self.m_model.m_data.mver, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
        self.m_model:getNetData("ancient_sword_and_wonderland_recv_key", params, netCallback)
    elseif cell_type == 23 then --祝福使者
        local function localClickCallBack( moveFinish )
            if moveFinish.select_index == nil or moveFinish.select_index == -1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0357"), delay_close = 2})
                if SceneManager.curScene.resetClickRoom ~= nil then
                    SceneManager.curScene:resetClickRoom();
                end
                return
            end
            if clickCallBack ~= nil then
                clickCallBack( moveFinish );
            end
        end
        self:openView("GuJianQiTan.GuJianQiTanMazeBless", {data = data, callBack = localClickCallBack})
    elseif cell_type == 24 then --邪剑熔炉
        local function localClickCallBack( moveFinish )
            if moveFinish.select_index == nil or moveFinish.select_index == -1 then
                -- GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0357"), delay_close = 2})
                if SceneManager.curScene.resetClickRoom ~= nil then
                    SceneManager.curScene:resetClickRoom();
                end
                return
            end
            if clickCallBack ~= nil then
                clickCallBack( moveFinish );
            end
        end
        self:openView("GuJianQiTan.GuJianQiTanMazeMelt", {msg_data = data, main_data = self.m_model.m_data, callBack = localClickCallBack})
    end
    audio:SendEvtUI("Play_UI_Enemy")
end

--宝箱
function M:requestForRewardBox(data)
    --宝箱
    --local params = {
    --    on_ok_call = function(msg)
    --        
    --    end,
    --    on_cancel_call = function(msg)
    --        
    --    end,
    --    no_close_btn = false,
    --    tow_close_btn = true,
    --    text = Language:getTextByKey("new_str_0615")
    --}
    --static_rootControl:openView("Pops.CommonPop", params)
    --self:updateMsg("maze_goto_guide")
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        if self.m_view and response then
            self.m_model:netData(response)
            self.m_view:refreshUI()
            self.m_view:showLevelEffect();
            SceneManager.curScene:handlerFinish();
            RewardUtil:rewardTipsByData(response.reward, nil, function()
                --local floor_ids = self.m_model:getNextFloorIds()
                --local floor_id = floor_ids[1]
                if UserDataManager.guide_data:isGuiding() then
                    self:updateMsg("guide_check")
                end
                --if floor_id == nil then
                -- self:openView("MazeStage.MazeStageBattleOver", {data = self.m_model.m_data})
                --end
                --弹结算
            end, {allDouble = self.m_model.doubleReward})
        else
            if SceneManager.curScene.resetClickRoom ~= nil then
                SceneManager.curScene:resetClickRoom();
            end
        end
    end
    local params = {cell_id = data.id,mver = self.m_model.m_data.mver, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
    self.m_model:getNetData("ancient_sword_and_wonderland_recv_reward", params, netCallback, nil, true)
end

function M:lockBoxWithoutKeyTips()
    if SceneManager.curScene.resetClickRoom ~= nil then
        SceneManager.curScene:resetClickRoom();
    end
    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_048", self.m_model.m_data.keys or 0), delay_close = 2})
end

function M:sendOpenDoorNet( data )
    local function netCallback(response)
        self.m_next_enter_lock = false
        if self:responseExpirtCheck(response) == false then
            return
        end
        if response ~= nil then
            if response.finish == 1 then
                --判断是否还有宝箱
                SceneManager.curScene:clickSure(data.cell_type, function()
                    self.m_view:lockTouch()
                    self:setOnceTimer(0.6, function()
                        self.m_view:unlockTouch()
                        self:openView("GuJianQiTan.GuJianQiTanMazeBattleOver", {data = response})
                    end)
                end)
            else
                SceneManager.curScene:clickSure(data.cell_type, function()
                    SceneManager.curScene:handlerFinish()
                    SceneManager.curScene:ShowMazeEffect();
                    SceneManager.curScene:resetSceneData(self.m_model)
                    self:setOnceTimer(0.5, function()
                        if self.m_view then
                            self.m_view:refreshUI()
                            self:setOnceTimer(0.7, function()
                                if response.recv_heirloom ~= nil and _G.next(response.recv_heirloom) then
                                    local m_data = {}
                                    m_data.heirloom_pool = response.recv_heirloom;
                                    --弹选择遗物
                                    self:openView("GuJianQiTan.GuJianQiTanMazeRelicSelect", { data = m_data, show_tips = false})
                                end
                            end)
                            --SceneManager:changeScene(SceneManager.SceneID.MiGongScene,self.m_model)
                        end
                    end)
                end)
            end
        end
    end
    self.m_next_enter_lock = true
    local params = {}
    params.version = self.m_model.m_version
    params.cur_round = self.m_model.m_cur_round
    self.m_model:getNetData("ancient_sword_and_wonderland_enter_next", params, netCallback, nil,true)
end


function M:afterOpenCellPop(data)
    local cell_type = data.type
    if cell_type == 1 or cell_type == 2 or cell_type == 3 or cell_type == 10 or cell_type == 11 then
        -- self.m_model.m_select_id = data.id
      --  self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
        --    if open_flag == "open_view" then
                self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE, def_data = data, death_hero_oids = self.m_model:getDeathHeroOids(), assist_heros = self.m_model.m_data.assist_heros, heirlooms = self.m_model.m_data.heirlooms, dyns = self.m_model.m_data.dyns})
         --   end
       -- end })
    else
        local new_data = self.m_model:getMazeCellDataById(data.id, true)
        self:setOnceTimer(0.5,function()
            self:openCellPop(new_data)
        end)
    end
end

-- 前往格子 cell_id: 格子id
function M:mazeGoto(data)
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        if self.m_view then
            self.m_view:refreshUI()
            if SceneManager.curScene ~= nil then
                SceneManager.curScene:rpgGoto(response);
            end
        end
    end
     --self:mazeGotoAfter(data, param)
    local params = {path = data.path,cell_id = data.cell_id, mver = self.m_model.m_data.mver, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
    self.m_model:getNetData("ancient_sword_and_wonderland_goto", params, netCallback, 0)
end

function M:mazeGotoAfter(data, param)
    --1.小怪 2.精英 3.boss 4.客栈 5.医馆 6.药王庙 7.商铺 8.空格 9.起点 10.怨灵马车 11.宝藏洞窟
    local cell_type = data.type
    local open_flag = self.m_model:getMazeCellIsOpen(data.id, true)
    if cell_type == 1 or cell_type == 2 or cell_type == 3 then
        self.m_model.m_select_id = data.id
        if data.status == 2 then
            self:openView("GuJianQiTan.GuJianQiTanMazeRelicSelect", {data = data})
        else
            self:updateMsg("goto_battle", {data = data})
        end
    elseif cell_type == 4 then
        --self:updateMsg("maze_employ", {hero_oid = param})
    elseif cell_type == 5 then --5.医馆
        self:updateMsg("maze_add_blood")
    elseif cell_type == 6 then -- 6.药王庙
        self:updateMsg("maze_revive_one")
    elseif cell_type == 7 then
        if param == nil then
            self:updateMsg("maze_give_up")
        else
            self:updateMsg("maze_buy", {pos = param})
        end
    elseif cell_type == 10 or cell_type == 11 then
        self.m_model.m_select_id = data.id
        self:updateMsg("goto_battle", {data = data})
    end
end

--客栈雇佣 hero_oid: 英雄唯一id
function M:mazeEmploy(data)
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        if not response then
            return
        end
        TimeTools:delayTimeUnity(1,function()
            if SceneManager.curScene.resetClickRoom ~= nil then
                SceneManager.curScene:resetClickRoom();
            end
        end)
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:handlerFinish();
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0190"), delay_close = 2})
        end
    end
    local params = {cell_id = data.data.id, hero_oid = data.param, mver = self.m_model.m_data.mver, replace_hero_oid = data.replace_hero_oid, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
    self.m_model:getNetData("ancient_sword_and_wonderland_employ", params, netCallback, nil, true)
end

--祝福使者
function M:mazeBless(data)
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        TimeTools:delayTimeUnity(1,function()
            if SceneManager.curScene.resetClickRoom ~= nil then
                SceneManager.curScene:resetClickRoom();
            end
        end)
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:handlerFinish();
            --GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0190"), delay_close = 2})
        end
    end
    local params = {cell_id = data.cell_id, buff_index = data.buff_index, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
    self.m_model:getNetData("ancient_sword_and_wonderland_messenger_of_blessings", params, netCallback, nil, true)
end

--邪剑熔炉
function M:mazeMelt(data)
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        TimeTools:delayTimeUnity(1,function()
            if SceneManager.curScene.resetClickRoom ~= nil then
                SceneManager.curScene:resetClickRoom()
            end
        end)
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:handlerFinish();
            if response and response.status ~= 0 then
                GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gu_jian_qi_tan_str_047"), delay_close = 2})
            end
        end
    end
    local params = {cell_id =  self.m_model.m_select_id, oid = data.hero_id, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
    self.m_model:getNetData("ancient_sword_and_wonderland_evil_sword_melting_pot", params, netCallback, nil, true)
end

-- 使用还魂丹复活所有
function M:mazeReviveAll()
	local cost = ConfigManager:getCommonValueById(47)
	if _G.next(cost) then
        local cost_data = RewardUtil:getProcessRewardData(cost[1])
        if cost_data.data_num > cost_data.user_num then
            local flag = QuickOpenFuncUtil:hasCostsTips(cost)
            if not flag then
                GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0098", cost_data.name), delay_close = 2})
            end
            return
        end
    end
    local function netCallback(response)
        if self.m_view then
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0181"), delay_close = 2})
            self:updateMsg("refresh_ui", {data = self.m_model.m_data}, "GuJianQiTan.GuJianQiTanMazeHeros")
        end
    end
    local params = {mver = self.m_model.m_data.mver}
    --self.m_model:getNetData("maze_revive_all", params, netCallback)
    --取消
end

-- 医馆回血
function M:mazeAddBlood(data)
    local need_flag = self.m_model:needAddBlood()
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:handlerFinish();
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey(need_flag and "new_str_0192" or "new_str_0191"), delay_close = 2})
        end
    end
    if need_flag then
        self.m_model:getNetData("ancient_sword_and_wonderland_add_blood", {cell_id = data.data.id,mver = self.m_model.m_data.mver, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}, netCallback)
    else
        local params =
        {
            on_ok_call = function(msg)
                self.m_model:getNetData("ancient_sword_and_wonderland_add_blood", {cell_id = data.data.id,mver = self.m_model.m_data.mver, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}, netCallback)
            end,
            text = Language:getTextByKey("new_str_0193"),
        }
        self:openView("Pops.CommonPop", params)
    end
end

-- 药王庙随机复活一人
function M:mazeReviveOne(data)
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:handlerFinish();
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0195"), delay_close = 2})
        end
    end
    local params = {cell_id = data.data.id,mver = self.m_model.m_data.mver, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
    self.m_model:getNetData("ancient_sword_and_wonderland_revive_one", params, netCallback)
end

-- 选择遗物 heirloom_id: 遗物id
function M:mazeSelectHeirloom(data)
    local heirloom_id = data.heirloom_id    
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:handlerFinish();
            -- self:openView("Pops.RelicReward", {heirlooms = {heirloom_id}})
            self:runHeirloomAnim(data.select_cell_obj, heirloom_id)
            self:closeView("GuJianQiTan.GuJianQiTanMazeRelicSelect")
            self:updateMsg("guide_check")
        end
    end
    local params = {heirloom_id = heirloom_id, mver = self.m_model.m_data.mver, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
    self.m_model:getNetData("maze_select_heirloom", params, netCallback)
end

function M:runHeirloomAnim(select_cell_obj, heirloom_id)
    local heirloom = ConfigManager:getCfgByName("heirloom")
    local heirloom_item = heirloom[heirloom_id] or {}
    --self.m_view:selectRelicMoveAnim(select_cell_obj, heirloom_item.quality or 0)
    --取消
end

-- 领取当前层奖励
function M:mazeRecvReward()
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:resetData();
            RewardUtil:rewardTipsByData(response.reward, nil, function()
                --local floor_ids = self.m_model:getNextFloorIds()
                --local floor_id = floor_ids[1]
                --if floor_id == nil then
                   -- self:openView("MazeStage.MazeStageBattleOver", {data = self.m_model.m_data})
                --end
            end)
        end
    end
    local params = {mver = self.m_model.m_data.mver, version = self.m_model.m_version, cur_round = self.m_model.m_cur_round}
    self.m_model:getNetData("ancient_sword_and_wonderland_recv_reward", params, netCallback)
    audio:SendEvtUI("UI_TresureChest_Open1")
end

-- 放弃当前格子
function M:mazeGiveUp()
    local function netCallback(response)
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:handlerFinish();
        end
    end
    local params = {mver = self.m_model.m_data.mver}
    --self.m_model:getNetData("maze_give_up", params, netCallback)
    --audio:SendEvtUI("Play_UI_Cancel")
    --取消
end

--奇珍阁购买 pos: 商品的位置
function M:mazeBuy(data)
    local function netCallback(response)
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager.curScene:handlerFinish();
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("update_data", response, "GuJianQiTan.GuJianQiTanMazeShop")
        end
    end
    local params = {cell_id = data.data.id ,pos = data.pos, mver = self.m_model.m_data.mver}
    --self.m_model:getNetData("maze_buy", params, netCallback)
    --audio:SendEvtUI("Ui_NormalClick")
    --取消
end

-- 进入下一层 floor_id: 层id
function M:mazeEnterNext(floor_id)
    --local floor_ids = self.m_model:getNextFloorIds()
    --floor_id = floor_ids[1]
    --if floor_id == nil then
    --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0349"), delay_close = 2})
    --    return
    --end
    local function netCallback(response)
        if self:responseExpirtCheck(response) == false then
            return
        end
        if self.m_view then
            self.m_view:refreshUI()
            SceneManager:changeScene(SceneManager.SceneID.GuJianQiTanScene, self.m_model, true);
        end
    end
    local params = {}
    params.version = self.m_model.m_version
    params.cur_round = self.m_model.m_cur_round
    self.m_model:getNetData("ancient_sword_and_wonderland_enter_next", params, netCallback)
end

--true，活动正常； false，活动过期
function M:responseExpirtCheck(response)
    if response and response.update == 1 then
        self:updateMsg("refresh")
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_063"), delay_close = 2})
        return false
    end
    return true
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "GuJianQiTan.GuJianQiTanMazeBattleOver" then
        self:updateMsg(99999)
    end
end

--计时器
function M:updateTime()
    self.m_view:updateRemainTime()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    M.super.destroy(self)
end

return M