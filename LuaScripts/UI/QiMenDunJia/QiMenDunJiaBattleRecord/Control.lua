local M = class("QiMenDunJiaBattleRecordControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("main_refresh_red_point", nil, "QiMenDunJia.QiMenDunJiaMain")
        self:closeView()
    elseif msg == "reward_btn" then
        audio:SendEvtUI("UI_TJL_Gold")
        self:questForReward(data)
    elseif msg == "handle_point_btn" then
        audio:SendEvtUI("UI_All")
        self.m_model:setTargetMember(data.index)
        self.m_view:updateRecordLoopScroll()
        self.m_view.m_loopscroll_record_view:moveToCellIndex(data.index)
    end
end

function M:questForReward()
    local function netCallback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateRewardData(response.show_reward)
            self.m_view:updateRewardInfo()
        end
    end
    local params = {}
    params.ver = self.m_model:getVersion()
    self.m_model:getNetData("gve_guild_reward_recv", params, netCallback)
end

return M