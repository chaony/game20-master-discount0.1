local M = class("RacconXkzDetailControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_index", nil, "LanternFestival")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
    elseif msg == "hero_btn1" then
        self:openXkzDetail(1)
    elseif msg == "hero_btn2" then
        self:openXkzDetail(2)
    elseif msg == "hero_btn3" then
        self:openXkzDetail(3)
    elseif msg == "help_btn" then
        local params = {}
        local open_condition = ConfigManager:getCfgByName("open_condition")
        local o_item = open_condition[341] or {}
        params.title = o_item.name or "raccon_text_0003"
        params.content = "tid#XiaoHuanXiongDes_3"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "detail_reward_btn" then --领取奖励
        self:questRewardTaskDetail(data)
    elseif msg == "detail_goto_btn" then  --跳转活动
        static_rootControl:closeAllViewPop()
        local go_type = data.go_type or {}
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "go_battle" then
        audio:SendEvtUI("UI_Chat_Open")
        if data then
            local index = data.index
            local pos_index = data.pos_index
            local data, id_tab = self.m_model:getStageData()
            if data[index] and data[index][pos_index] then
                self.m_model.m_cur_cell_group = index
                local stage_cfg = data[index][pos_index]
                local stage_id = id_tab[index][pos_index]
                local isCost = self.m_model:isCost(stage_id)
                if isCost then
                    self:startBattle(stage_cfg, stage_id)
                else
                    self:goStageIndex(stage_cfg, stage_id)
                end
            end
        end
    elseif msg == "rebattle" then
        if data then
            local params = {}
            params.stage_id = data.stage_id
            params.hero_index = data.raccon_hero_id
            params.battle_id = data.battle_id
            params.mode =  data.mode
            self:openView("Formation",params)
        end    
    elseif msg == "box_click" then
        audio:SendEvtUI("UI_Pay")
        local rewards = data.data.rewards or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.status == -1})
    elseif msg == "box_reward" then
        audio:SendEvtUI("UI_Pay")
        local box_id = data.data.box_id or 0
        self:getBoxReward(box_id)
    elseif msg == "unlock_new_chapter" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("raccon_text_0019"), delay_close = 2})
        if data then
            --raccon_text_0019
        else

        end
    elseif msg == "update_data" then
        if data then
            if data.reward then
                RewardUtil:rewardTipsByData(data.reward)
            end
            self.m_model:updateData(data)
            self.m_view:refreshUI(true)
        end
    end
end

function M:goStageIndex(stage_cfg, stage_id)
    local function receivetCallback(response)
        self.m_model:updateData(response)
        self:updateMsg("update_data", response, "Raccon.RacconXkz")
        self:startBattle(stage_cfg, stage_id)
        self.m_view:refreshUI()
    end
    local params = {}
    params.hero_id = self.m_model.m_hero_index
    params.stage_id = stage_id
    self.m_model:getNetData("raccon_stage_index", params, receivetCallback)
end

function M:openXkzDetail(hero_index)
    self:openView("Raccon.Raccon", {pop_from_func_id = -1})
end

function M:destroy()
    M.super.destroy(self)
end

function M:getBoxReward(box_id)
    local function netCallback(response)
        if response.update then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:closeView()
            return
        end
        if response["end"] then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:closeView()
            return
        end
        if response and response.reward then
            RewardUtil:rewardTipsByData(response.reward)
        end
        self.m_model:updateData(response)
        self:updateMsg("update_data", response, "Raccon.RacconXkz")
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("raccon_stage_recv", {score_id = box_id, hero_id = self.m_model.m_hero_index}, netCallback)
end

function M:startBattle(cur_stage_cfg, stage_id)
    --if self.m_model:stageCheck() == true then
        local stage_cfg = self.m_model:getFormationData(cur_stage_cfg)
        if stage_cfg then
            local is_battle = cur_stage_cfg.battle_id > 0
            local stage_done_flag = false--self.m_model:checkStageDone(stage_cfg.id)
            if stage_done_flag == false and stage_cfg.win_event then
                UserDataManager:setTempData("Raccon_win_event", stage_cfg.win_event)
            else
                UserDataManager:setTempData("Raccon_win_event", 0)
            end
            if stage_done_flag == false and stage_cfg.open_event then
                self:openView("Raccon.RacconShowBeforeStory", {cfg_type = stage_cfg.cfg_type,
                                                               is_battle = is_battle,
                                                               mode = GlobalConfig.BATTLE_MODE.RACCON,
                                                               stage_id = stage_id,
                                                               battle_id = stage_cfg.battle_id,
                                                               hero_index = self.m_model.m_hero_index,
                                                               open_event = stage_cfg.open_event})
            else
                self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.RACCON, stage_id = stage_cfg.id})
            end
        end
    --else
    --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_014", self.m_model:getSelectedStageUnlockName()), delay_close = 2 })
    --end
   
end

return M;
