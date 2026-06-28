local M = class("OnTimePopControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "get_reward_btn" then
        self:getOnTimeReward()
    end
end

--在线奖励
function M:getOnTimeReward()
    local function receivetCallback(response)
        if response["end"] == 1 then
            RewardUtil:rewardTipsByData(response.reward or {})
            self:updateMsg(99999)
            return
        end
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:refreshData(response)
        self.m_view:refreshUI()
        self:updateTime()
    end
    local params = {}
    self.m_model:getNetData("receive_online_reward", nil, receivetCallback)
end

function M:updateTime()
    self.m_view:updateTime()
end

return M
