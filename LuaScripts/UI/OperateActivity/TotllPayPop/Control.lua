local M = class("TotllPayPopControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        self:closeView()
    elseif msg == "get_reward_btn" then
        self:getReward(data)
    end
end

function M:getReward(data)
    local function callback(response)
        self.m_model.m_continuous_data = response.continuous_payment
        self.m_model.max_day = self.m_model:getMaxRecharge()
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
        self:updateMsg("refreshUI", nil, "TopUpGiftBag")
    end
    local params = {}
    params.day = data
    self.m_model:getNetData("receive_continuous", params, callback)
end


function M:updateTime()
    self.m_view:updateTime()
end

return M
