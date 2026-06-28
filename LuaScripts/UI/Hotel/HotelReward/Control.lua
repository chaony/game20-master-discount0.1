local M = class("HotelRewardControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "get_reward_btn" then
        self:requestReward()
    end
end

function M:requestReward()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return
        end
        RewardUtil:rewardTipsByData(response.reward) --展示奖励
        self:updateMsg("get_daily_reward", nil, "Hotel")
        self:closeView()
    end
    self.m_model:getNetData("hotel_daily_award", nil, netCallback)
end

return M