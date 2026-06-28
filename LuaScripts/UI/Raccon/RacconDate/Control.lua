local M = class("RacconDateControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint", nil, "Raccon")
        self:closeView()
    elseif msg == "detail_reward_btn" then
        self:questRewardTaskDetail(data)
    elseif msg == "detail_goto_btn" then
        audio:SendEvtUI("Play_UI_NormalClick")
        local go_type = data.go_type or {}
        if go_type == 10052 then
            self:updateMsg("fctj_btn", nil, "Raccon")
        else
            QuickOpenFuncUtil:openFunc(go_type)
        end
        self:updateMsg(99999)
    elseif msg == "zhuanji_item" then
       self:touchZhuanjiItem(data)
        audio:SendEvtUI("UI_Popup_N2")
    elseif msg == "box_click" then
        audio:SendEvtUI("Play_UI_TresureChest")
        local rewards = data.data.cfg.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
    elseif msg == "box_reward" then
        audio:SendEvtUI("UI_Pay")
        self:questRewardBox(data.data)
    elseif msg == "look_hero_info" then
        self:showHeroInfo()
    elseif msg == "help_btn" then
        local info_data = self.m_model:getRacconActiveCfg() --获取配置
        local params = {}
        params.title = self.m_model.m_act_name
        params.content = info_data.raccoon_active_des
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:questRewardTaskDetail(data)
    local function netCallback(response)
        if response then
            self.m_model:setTaskDetailCfgData(response.quests)
            self.m_view:updateZhuanjiDetailLoopScroll()
            self.m_model:updateRewardBoxDataScore(response.score)
            self.m_model:updateRewardBoxData()
            self.m_view:updateRewardBox()
            self.m_view:updateZhuanjiLoopScroll()
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
        end
    end
    local params = {}
    params.open_id = self.m_model.open_id
    params.vsn = self.m_model:getVersion()
    params.quest_id = data.quest_id
    self.m_model:getNetData("common_quest_recv_task", params, netCallback)
end

function M:touchZhuanjiItem(data)
    if data.day <= self.m_model:getCurrentDay() and data.day ~= self.m_model:getCurrentDayUpdate() then
        self.m_model:setCurrentDayUpdate(data.day)
        self.m_view:refreshUI()
    end
end

function M:questRewardBox(data)
    local function netCallback(response)
        self.m_model:updateRewardBoxDataScoreDone(response.score_done)
        self.m_model:updateRewardBoxData()
        self.m_view:updateRewardBox()
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {}
    params.open_id = self.m_model.open_id
    params.vsn = self.m_model:getVersion()
    params.score_id = data.id
    self.m_model:getNetData("common_quest_recv_score", params, netCallback)
end

function M:showHeroInfo()
    self:closeView("Pops.HeroLookInfo",nil, false)
    self:openView("Pops.HeroLookInfo", {hero_id = self.m_model.m_hero_id, is_new = false})
end

return M
