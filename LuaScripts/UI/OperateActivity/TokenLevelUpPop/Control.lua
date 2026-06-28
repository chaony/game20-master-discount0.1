local M = class("TokenLevelUpPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        self:closeView()
    elseif msg == "buy_btn" then
        if self.m_model.m_token_id == 80 then
            self:getRoyalLv()
        elseif self.m_model.m_token_id == 286 then
            -- 小游戏特权
            self:getminiGameLv()
        elseif self.m_model.m_token_id == 109 then
            self:getWarriorLv()
        else
            self:getGoalCommonLv()
        end
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

--皇家犒赏令奖励
function M:getRoyalLv()
    if self.m_model:getRewardId() then
        local function receivetCallback(response)
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("update_token", response, "OperateActivity")
            self:updateMsg("update_task_token", nil, "Task")
            -- self.m_model.m_lv = self.m_model:getRewardId()
            -- self.m_model.m_buy_lv = 1
            -- self.m_view:refreshUI()
            self:updateMsg(99999)
        end
        local reward_id = self.m_model:getRewardId()
        self.m_model:getNetData("buy_royal_unreached_reward", {vsn = self.m_model.m_vsn, reward_id = reward_id}, receivetCallback)
    end
end


--勇者犒赏令奖励
function M:getWarriorLv()
    if self.m_model:getRewardId() then
        local function receivetCallback(response)
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("update_token", response, "OperateActivity")
            self:updateMsg("update_task_token", nil, "Task")
            -- self.m_model:updateData(response)
            -- self.m_view:refreshUI()
            self:updateMsg(99999)
        end
        local reward_id = self.m_model:getRewardId()
        self.m_model:getNetData("buy_warrior_unreached_reward", {vsn = self.m_model.m_vsn, reward_id = reward_id}, receivetCallback)
    end
end

--皇家犒赏令奖励
function M:getGoalCommonLv()
    if self.m_model:getRewardId() then
        local function receivetCallback(response)
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("update_token", response, "OperateActivity")
            self:updateMsg("update_task_token", nil, "Task")
            self:updateMsg(99999)
        end
        local reward_id = self.m_model:getRewardId()
        self.m_model:getNetData("buy_goal_common_reward", {open_id = self.m_model.m_token_id, vsn = self.m_model.m_vsn, reward_id = reward_id}, receivetCallback)
    end
end

return M
