---@class SettlementView:OOPopBase
local M = class("SettlementView",LikeOO.OOPopBase)

M.m_uiName = "Settlement/Settlement"
-- M.m_iphoneXAdapter = true
M.m_cache_ui_flag = true

local __SETTLEMENT_TAB = {
    [GlobalConfig.BATTLE_MODE.STAGE] = { -- 推关
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.TOWER] = { -- 爬塔
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.RACE_TOWER] = { -- 种族爬塔
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.MAZE] = { -- 迷宫 
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.LOCAL_ARENA] = { -- 竞技场
        [0] = {lua_name = "UI.Settlement.SettlementArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementArenaWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.RACE_ARENA] = { -- 竞技场
        [0] = {lua_name = "UI.Settlement.SettlementArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementArenaWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.HIGH_ARENA] = { -- 高阶竞技场
        [0] = {lua_name = "UI.Settlement.SettlementArenaHigherLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementArenaHigherWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.WORLD_BOSS] = {
        [0] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.ACTIVE_BOSS] = {
        [0] = {lua_name = "UI.Settlement.SettlementActiveBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementActiveBossWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.TOP_OF_TIME] = {  --时光之巅
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.UNION_BOSS] = { --世界boss
        [0] = {lua_name = "UI.Settlement.SettlementUnionBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementUnionBossWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.FIVE_ARRAY] = { --五行阵
        [0] = {lua_name = "UI.Settlement.SettlementFiveElementNode"},
        [1] = {lua_name = "UI.Settlement.SettlementFiveElementNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.EVIL_SHADOW] = { --邪极魅影
        [0] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS] = { --三侠五义
        [0] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        ["ShowHeroSettlement"] = true
    },  
    [GlobalConfig.BATTLE_MODE.COMMON_BATTLE] = { --通用试炼
        [0] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.DRAGONSWORD] = { --龙泉试炼
        [0] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.FOUR_TOWER] = { --四象阵
        [0] = {lua_name = "UI.Settlement.SettlementFiveElementNodeNew"},
        [1] = {lua_name = "UI.Settlement.SettlementFiveElementNodeNew"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.BIOGRAPHY] = { -- 传记
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.ACTIVE] = { -- 活动
        [0] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.BIG_MAP] = { -- 传记
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.NEW_BIG_MAP] = { -- 随机江湖
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.RAID] = { -- 武道场
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.LEGEND] = { -- 江湖传说
        [0] = {lua_name = "UI.Settlement.SettlementLegendNode"},
        [1] = {lua_name = "UI.Settlement.SettlementLegendNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.MINING] = { -- 苗疆觅宝
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.ACTIVE_MINING] = { -- 夺宝奇兵
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA] = { -- 天级赛
        [0] = {lua_name = "UI.Settlement.SettlementTopArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementTopArenaWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.UNIONWAR] = { -- 公会战
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementUnionWarChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA] = { -- 天级赛
        [0] = {lua_name = "UI.Settlement.SettlementTopArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementTopArenaWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL] = { -- 争锋联赛多队
        [0] = {lua_name = "UI.Settlement.SettlementTopArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementTopArenaWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.ZF_ARENA] = { -- 争锋联赛单队
        [0] = {lua_name = "UI.Settlement.SettlementArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementArenaWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.FIVE_ARRAY_BOSS] = { --五行阵Boss
        [0] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementWorldBossWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.ACTIVE_TOWER] = { -- 爬塔
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.YINYANG_TOWER] = { --四象阵
        [0] = {lua_name = "UI.Settlement.SettlementFiveElementNodeNew"},
        [1] = {lua_name = "UI.Settlement.SettlementFiveElementNodeNew"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.MULT_STAGE] = { -- 推关
        [0] = {lua_name = "UI.Settlement.SettlementMultChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementMultChapterWinNode"},
        ["ShowHeroSettlement"] = true
    }, [GlobalConfig.BATTLE_MODE.HUASHAN_SWORD] = { -- 高阶竞技场
        [0] = {lua_name = "UI.Settlement.SettlementArenaHigherLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementArenaHigherWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.GVE_BATTLE] = { -- 奇门遁甲
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS] = { -- 奇门遁甲boss
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.WD_TOWER] = { --四象阵
        [0] = {lua_name = "UI.Settlement.SettlementFiveElementNodeNew"},
        [1] = {lua_name = "UI.Settlement.SettlementFiveElementNodeNew"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.GU_JIAN_MULT] = { -- 古剑奇谭，多队伍
        [0] = {lua_name = "UI.Settlement.SettlementMultGuJianLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementMultGuJianWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE] = { -- 古剑奇谭，迷宫 
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true 
    },
    [GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE] = { -- 风云擂台单队
        [0] = {lua_name = "UI.Settlement.SettlementFulwinArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementFulwinArenaWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE] = { -- 风云擂台三队
        [0] = {lua_name = "UI.Settlement.SettlementFulwinArenaTeamLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementFulwinArenaTeamWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.MYTH_ARENA] = { -- 武林神话淘汰赛
        [0] = {lua_name = "UI.Settlement.SettlementMythArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementMythArenaWinNode"},
        ["ShowHeroSettlement"] = false
    }, 
    [GlobalConfig.BATTLE_MODE.RACCON] = { -- 爬塔
        [0] = {lua_name = "UI.Settlement.SettlementChapterLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.PET_DOUJI] = { -- 宠物斗技
        [0] = {lua_name = "UI.Settlement.SettlementPetLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementPetWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM] = { -- 入梦铃
        [0] = {lua_name = "UI.Settlement.SettlementAwakenSystemNode"},
        [1] = {lua_name = "UI.Settlement.SettlementAwakenSystemNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS] = { --剑试天下 Boss战
        [0] = {lua_name = "UI.Settlement.SettlementSwordWorldBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementSwordWorldBossWinNode"},
        ["ShowHeroSettlement"] = true
    },

    [GlobalConfig.BATTLE_MODE.XIAKEDAO] = { --侠客岛单队
        [0] = {lua_name = "UI.Settlement.SettlementXiakedaoLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },

    [GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI] = { --侠客岛多队
        [0] = {lua_name = "UI.Settlement.SettlementXiakedaoLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementMultChapterWinNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.HERO_FATE] = { -- 侠客情缘
        [0] = {lua_name = "UI.Settlement.SettlementAwakenSystemNode"},
        [1] = {lua_name = "UI.Settlement.SettlementAwakenSystemNode"},
        ["ShowHeroSettlement"] = true
    },
    [GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE] = { -- 天府夺刀 pve
        [0] = {lua_name = "UI.Settlement.SettlementHeroBossWinNode"},
        [1] = {lua_name = "UI.Settlement.SettlementHeroBossWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.HERO_BOSS_PVP] = { -- 天府夺刀 pvp
        [0] = {lua_name = "UI.Settlement.SettlementArenaLostNode"},
        [1] = {lua_name = "UI.Settlement.SettlementHeroBossWinNode"},
        ["ShowHeroSettlement"] = false
    },
    [GlobalConfig.BATTLE_MODE.RTA_ARENA] = { --rta剑出红蒙
        [0] = {lua_name = "UI.Settlement.SettlementRTANode"},
        [1] = {lua_name = "UI.Settlement.SettlementRTANode"},
        ["ShowHeroSettlement"] = true
    }
}

local __UNIONWAR_TAB = {
    [GlobalConfig.BATTLE_MODE.UNIONWAR] = { -- 公会战
        [0] = {lua_name = "UI.Settlement.SettlementUnionWarNode"},
        [1] = {lua_name = "UI.Settlement.SettlementUnionWarNode"},
        ["ShowHeroSettlement"] = false
    }
}


function M:onEnter()
    self.m_content_panel = self:findGameObject("content_panel")
    local settlement_tab_item = __SETTLEMENT_TAB[self.m_model.m_mode]
    if self.m_model.m_five_pos == 0 then
        settlement_tab_item = __SETTLEMENT_TAB[GlobalConfig.BATTLE_MODE.FIVE_ARRAY_BOSS]
    end
    local issim = UserDataManager.local_data:getUserDataByKey("simulated_battle_flag", false)
    if self.m_model.bl_new_panel ~= 0 and settlement_tab_item.ShowHeroSettlement then --废弃
        local tab_cls = CustomRequire("UI.Settlement.SettlementTempNode")
        self.m_temp_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
    else
        local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_model.m_mode] or {}
        if battle_mode_cfg_item.show_result_bg ~= false then
            --if self.m_model.m_mode==Battle.BattleGlobalConfig.BATTLE_MODE.RTA_ARENA then
            --    self:LoadRTAResultsBg()
            --else
            --    self:LoadResultsBg()
            --end
            self:LoadResultsBg()

        elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR and not issim then
            self:LoadResultsBg()
        end
        if settlement_tab_item then
            local view_item = settlement_tab_item[self.m_model.m_result]
            if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR and issim then
                view_item = __UNIONWAR_TAB[self.m_model.m_mode][self.m_model.m_result]
            end
            if view_item then
                local tab_cls = CustomRequire(view_item.lua_name)
                self.m_cur_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
            end
        end
        -- 下一关 或 再次挑战
        self:setTextByLanKey("lost_ok_btn_text", "new_str_0242")
        self:setTextByLanKey("win_ok_btn_text", "new_str_0241")
        self:setTextByLanKey("next_text", "new_str_0243")
        self:setObjectVisible("record_btn", self.m_model:getShowRecordFlag())
        -- 战斗胜利光环
        EventDispatcher:registerTimeEvent("ShenliSound", function()
            audio:SendEvtUI(self.m_model.m_result == 0 and "UI_Lose" or 'Ui_Win')
        end ,0.5, 0.5)
    end
    self:findButton("big_close_btn").interactable = false
    self:setObjectVisible("content_panel", false)
    self:setObjectVisible("full_mask_img", self.m_model.m_full_mask_flag) -- 是否加全屏遮罩
end

function M:refreshUI()
    if self.m_cur_node ~= nil and self.m_cur_node.refreshUI ~= nil then
        self.m_cur_node:refreshUI()
    end
end


function M:battleResultSpineAnimEnd(delay_time)
    if self.m_model == nil then
        return
    end
    self:updateMsg("check_chapter_unlock")
    local new_chapter = self.m_model:getIsNewChapter()
    if new_chapter then -- 新章节开启不执行后面的流程
        self:findButton("big_close_btn").interactable = true
        return
    end
    delay_time = delay_time or 0.5
    EventDispatcher:registerTimeEvent("ShenliSound", function()
        self:setObjectVisible("content_panel", true)
        self:setObjectVisible("win_sp", false)
        self:setObjectVisible("lose_sp", false)
        self:findButton("big_close_btn").interactable = true
        if self.m_cur_node ~= nil and self.m_cur_node.sliderAnim ~= nil then
            self.m_cur_node:sliderAnim()
        end
        self:guideVisible()
        self:openChapterDownTime()
        if self.m_model.m_result == 0 then
            self.audio = audio:SendEvtUI('PLAY_UI_LOSE')
        else
            self.audio = audio:SendEvtUI('PLAY_UI_WIN')
        end
        NetWork:delayCheckHope()
    end ,delay_time, delay_time)
end

function M:playBattleEndStory()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
        local stage_cfg = UserDataManager:getTempData("battleStage");
        local result = self.m_model.m_result
        local dialog_id = result == 1 and stage_cfg.win_event or stage_cfg.lose_event
        if dialog_id ~= 0 then
            self:setObjectVisible("win_sp", false)
            self:setObjectVisible("lose_sp", false)
            self.m_control:openView("Guide.GuideDrama", {dialog_id = dialog_id, callback = function()
                self:battleResultSpineAnimEnd(0.1)
                audio:PauseMusicBusVol()
            end})
        else
            self:battleResultSpineAnimEnd()
            audio:PauseMusicBusVol()
        end
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        local win_event =  UserDataManager:getTempData("GuJianQiTan_win_event")
        local result = self.m_model.m_result
        if result == 1 and win_event ~= 0 then
            self:setObjectVisible("win_sp", false)
            self:setObjectVisible("lose_sp", false)
            self.m_control:openView("Guide.GuideDrama", {dialog_id = win_event, callback = function()
                self:battleResultSpineAnimEnd(0.1)
                audio:PauseMusicBusVol()
            end})
        else
            self:battleResultSpineAnimEnd()
            audio:PauseMusicBusVol()
        end
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.BIOGRAPHY then
        local result = self.m_model.m_result
        if result == 1 then
            local biography_stage = ConfigManager:getCfgByName("biography_stage")
            local stage_cfg = biography_stage[self.m_model.m_params.stage_id] or {}
            if stage_cfg.story02 and stage_cfg.story02 ~= 0 then
                self:setObjectVisible("win_sp", false)
                self:setObjectVisible("lose_sp", false)
                self.m_control:openView("Guide.GuideDrama", {dialog_id = stage_cfg.story02, dialogue_type = GlobalConfig.WORLD_MAP_EVENT.BIOGRAPHY, callback = function()
                    self:battleResultSpineAnimEnd(0.1)
                    audio:PauseMusicBusVol()
                end})
            else
                self:battleResultSpineAnimEnd()
                audio:PauseMusicBusVol()
            end
        else
            self:battleResultSpineAnimEnd()
            audio:PauseMusicBusVol()
        end
    else
        self:battleResultSpineAnimEnd()
        audio:PauseMusicBusVol()
    end
end

function M:openTransitionEnd()
    self.m_model.autoChapterNextOpen = false
    if self.m_model:checIsSkip() == true then
        self:setObjectVisible("win_sp", false)
        self:setObjectVisible("lose_sp", false)
        self.m_control:setOnceTimer(0.5, function()
            self:updateMsg(99999)
        end)
    else
        if self.m_model.m_replay then-- 不播放spine动画
            self:battleResultSpineAnimEnd(0.1)
            if self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.PET_DOUJI
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE then
                self:updateMsg("win_record_btn")
            end
        else
            if self.m_model.m_result == 1 then
                self:setObjectVisible("lose_sp", false)
                self:setObjectVisible("win_sp", true)
                -- local eff_obj = self:setObjectVisible("UI_Settlement_Win_001", true)
                -- self:setParticleRenderOrder(eff_obj)
                -- local obj = self:findGameObject("win_bg")
                -- local anim = obj:GetComponent("SkeletonGraphic")
                -- anim.AnimationState:SetAnimation(0, "victory_1", false)
                --self:addSpineComplete(anim.AnimationState,handler(self, self.playBattleEndStory))

                local function winCard(msg) 
                    self:playBattleEndStory()
                end
                local win_main = self:findGameObject("win_main")
                local win_main_luabehaviour = win_main:GetComponent("LuaBehaviour")
                win_main_luabehaviour:RunAnim("Zhandoushengli", nil)
                self.m_control:setOnceTimer(0.8, winCard)
                
            else
                self:setObjectVisible("lose_sp", true)
                self:setObjectVisible("win_sp", false)
                local function endCard(msg)
                    self:playBattleEndStory()
                end
                local lose_main = self:findGameObject("lose_main")
                local lose_main_luabehaviour = lose_main:GetComponent("LuaBehaviour")
                lose_main_luabehaviour:RunAnim("Zhandoushibai", nil)
                self.m_control:setOnceTimer(1.5, endCard)
                -- local obj = self:findGameObject("lose_bg")
                -- local anim = obj:GetComponent("SkeletonGraphic")
                -- anim.AnimationState:SetAnimation(0,"defeat", false)
                -- self:addSpineComplete(anim.AnimationState,handler(self, self.playBattleEndStory))
            end
        end
    end
end

function M:guideVisible()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
        if self.m_model.m_result == 0 then
            self.m_control.m_guide:checkGuide()
        else
            local open_func_ids, is_ahead = BtnOpenUtil:getCurStageOpenFuncs() -- 新功能开启
            if #open_func_ids > 0 then
                self.m_control:openView("Pops.NewFuncOpen", {open_func_ids = open_func_ids})
                if is_ahead == true then
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0950"), delay_close = 2})
                end
            else
                self.m_control.m_guide:checkGuide()
            end
        end
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING then
        self.m_control.m_guide:checkGuide()
    end
    local guide_info = UserDataManager.guide_data:getCurGuideInfo()
    if UserDataManager.guide_data:isGuiding() and guide_info.key == "Settlement" then
        --self:setObjectVisible("ok_btn", false)
        if self.m_model.bl_new_panel == 1 and (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE) then
            self.m_temp_node:update_ok_btn(false)
        else    
            if self.m_bg_node then
                self.m_bg_node:update_ok_btn(false)
                if self.m_cur_node ~= nil and self.m_cur_node.updateButtonVisible ~= nil then
                    self.m_cur_node:updateButtonVisible(false)
                end
            end
        end
    end
end

--开启五秒倒计时
function M:openChapterDownTime()
    local guide_info = UserDataManager.guide_data:getCurGuideInfo()
    if (UserDataManager.guide_data:isGuiding() and guide_info.key == "Settlement") or self.m_control:hasChild("Pops.NewFuncOpen") then
        return
    end
    self.m_model:setChapterDownTime()
    self.m_control:updateTime()
end

function M:LoadResultsBg()
    local tab_cls = CustomRequire("UI.Settlement.SettlementCommonBgNode")
    self.m_bg_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
    --self.m_bg_node:RigCallback(handler(self, self.bgRunEnd))
end

function M:LoadRTAResultsBg()
    local tab_cls = CustomRequire("UI.Settlement.SettlementRTALostBgNode")
    self.m_bg_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
end

function M:bgRunEnd()
    if self.m_cur_node then
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
           -- self.m_cur_node:playAnim()
        end 
    end
end

function M:showOverWord()
    if self.m_bg_node then
        self.m_bg_node:showOverWord()
    end
    if self.m_cur_node and self.m_cur_node.showOverWord then
        self.m_cur_node:showOverWord()
    end
end

function M:updateTime()
    if self.m_cur_node and self.m_cur_node.updateTime then
        self.m_cur_node:updateTime()
    end
end

function M:destroy()
    audio:StopPlayingID(self.audio)
    self.audio = nil
    if self.m_cur_node then
		self.m_cur_node:destroy()
		self.m_cur_node = nil
    end
    if self.m_bg_node then
		self.m_bg_node:destroy()
		self.m_bg_node = nil
	end
    audio:ResumeMusicBusVol()
    EventDispatcher:unRegisterEvent("ShenliSound")
    M.super.destroy(self)
end

return M
