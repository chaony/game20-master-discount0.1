local M = class("QiMenDunJiaTaskControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("main_refresh_red_point", nil, "QiMenDunJia.QiMenDunJiaMain")
        self:closeView()
    elseif msg == "refreshExploreScroll" then
        self.m_view:updateTitleNode()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "goto_btn" then
        audio:SendEvtUI("Play_UI_NormalClick")
        static_rootControl:closeAllViewPop()
        local go_type = data.go_type or {}
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "reward_btn" then
        audio:SendEvtUI("UI_Tab_N7")
        self:questForReward(data)
    elseif msg == "auto_get_btn" then
        audio:SendEvtUI("UI_Tab_N7")
        self:questForAllReward(self.m_model.m_select_tab_index) --1 个人， 2 帮会
    elseif msg == "box_click" then
        audio:SendEvtUI("Play_UI_TresureChest")
        local rewards = data.data.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
    elseif msg == "left_arrow_btn" then
        self.m_view:moveExploreProgressSliderLoopScrolllPage(-1)
    elseif msg == "right_arrow_btn" then
        self.m_view:moveExploreProgressSliderLoopScrolllPage(1)
    elseif msg == "box_reward" then --领取探索进度宝箱奖励
        self:questRewardBox(data.data)
    elseif msg == "reward_preview_btn" then
        self:openView("QiMenDunJia.QiMenDunJiaTaskRewardPreview", {main_data = self.m_model:getMainData(), explore_data = self.m_model:getExploreData()})
    elseif msg == "explore_view_update" then
        self.m_model:initExploreData()
        self.m_view:updateTitleNode()
    end
end

function M:switchTabBtn(index)
    if self.m_model.m_select_tab_index ~= index then
        self.m_model.m_select_tab_index = index
        self.m_view:switchNode(index)
    end
end

--领取奖励
function M:questForReward(data)
    local function netCallback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateTaskData(response)
            self.m_view:updateAllLoopScroll()
            self.m_view:refreshRedPoint()
        end
    end
    local params = {}
    params.ver = self.m_model:getVersion()
    params.quest_id = data.id
    self.m_model:getNetData("gve_recv_quest_reward", params, netCallback)
end

--领取全部奖励
function M:questForAllReward(type)
    local function netCallback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateTaskData(response)
            self.m_view:updateAllLoopScroll()
            self.m_view:updateTitleNode()
            self.m_view:updateExploreProgressLoopScrollStatus()
            self.m_view:refreshRedPoint()
        end
    end
    local params = {}
    params.ver = self.m_model:getVersion()
    params.type = type
    self.m_model:getNetData("gve_auto_recv", params, netCallback)
end

--领取宝箱奖励
function M:questRewardBox(data)
    self.m_model:setExploreProgressLoopScrollPosition(self.m_view:getExploreProgressLoopScrollPosition())
    
    local function netCallback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateExploreDoneData(response.explore_done)
            self.m_view:updateTitleNode()
            self.m_view:updateExploreProgressLoopScrollStatus()
            self.m_view:refreshRedPoint()
        end
    end
    local params = {}
    params.ver = self.m_model:getVersion()
    params.reward_id = data.id
    self.m_model:getNetData("gve_recv_explore_reward", params, netCallback)
end

return M
