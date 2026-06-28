local M = class("SimulateTokenLevelUpPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        self:closeView()
    elseif msg == "buy_btn" then
        -- 小游戏特权
        self:getminiGameLv()
    elseif msg == "add_btn" then
        self.m_model:changeBuyNum(true)
        self.m_view:refreshUI()
    elseif msg == "sub_btn" then
        self.m_model:changeBuyNum(false)
        self.m_view:refreshUI()
    end
end

function M:getminiGameLv()
    if self.m_model:getRewardId() then
        local function receivetCallback(response)
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("update_token", response, "SimulateLift.SimulateToKen")
            self:updateMsg(99999)
        end
        local reward_id = self.m_model:getRewardId()
        self.m_model:getNetData("buy_mini_game_unreached_reward", {vsn = self.m_model.m_vsn, reward_id = reward_id}, receivetCallback)
    end
end

return M
