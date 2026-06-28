local M = class("QiMenDunJiaTaskRewardPreviewControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshExploreScroll", nil, "QiMenDunJia.QiMenDunJiaTask")
        self:closeView()
    elseif msg == "goto_btn" then
        audio:SendEvtUI("Play_UI_NormalClick")
        static_rootControl:closeAllViewPop()
        local go_type = data.go_type or {}
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "reward_btn" then
        self:questForReward(data)
    end
end

function M:questForReward(data)
    local function netCallback(response)
        if response then
            self.m_model:updateExploreDoneData(response.explore_done)
            self.m_view:updateLoopScroll()
            self:updateMsg("explore_view_update", nil, "QiMenDunJia.QiMenDunJiaTask") --更新任务界面的探索宝箱
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local params = {}
    params.ver = self.m_model:getVersion()
    params.reward_id = data.id
    self.m_model:getNetData("gve_recv_explore_reward", params, netCallback)
end


return M
