local M = class("ActiveCurrentDailyRewardControl",LikeOO.OOControlBase)

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
        self.m_model.m_daily_recv_rewards = response.daily_recv_rewards or 0
        local params = {key = "daily_recv_rewards", value = self.m_model.m_daily_recv_rewards}
        self:updateMsg("update_net_data_key", params, "ActiveCurrent.ActiveCurrentMain")
        self:updateMsg("udpate_daily_recv_rewards", self.m_model.m_daily_recv_rewards, "ActiveCurrent.ActiveCurrentGrow")
        
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = self.m_model:getCurRewardId()
    self.m_model:getNetData("hero_event_receive_daily_reward",{version = self.m_model.m_version, reward_id = self.m_model:getCurRewardId() }, netCallback)
end


return M
