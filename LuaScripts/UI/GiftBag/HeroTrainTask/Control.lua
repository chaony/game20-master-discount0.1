local M = class("HeroTrainTaskControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "get_reward" then
        self:getReward(data)
    elseif msg == "auto_get_btn" then --一键领取
        self:getRewardAll()
    end
end

function M:getReward(data)
    local function callback(response)
        if response.update then
            self:updateMsg("update_data", self.m_model.m_data, "Activities.WorldBoss.HeroBossTrainPop")
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            self:updateMsg(99999)
            return
        end
        self.m_model:updateQuests(response)
        self:updateMsg("update_quest", response.quests, "Activities.WorldBoss.HeroBossTrainPop")
        self:updateMsg("update_quest", response.quests, "Activities.WorldBoss.WorldBossSelectMain")
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data
    params.version = self.m_model.version;
    self.m_model:getNetData("train_challenge_recv_reward", params, callback)
end

--一键领取
function M:getRewardAll()
    local function callback(response)
        if response.update then
            self:updateMsg("update_data", self.m_model.m_data, "Activities.WorldBoss.HeroBossTrainPop")
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            self:updateMsg(99999)
            return
        end
        self.m_model:updateQuests(response)
        self:updateMsg("update_quest", response.quests, "Activities.WorldBoss.HeroBossTrainPop")
        self:updateMsg("update_quest", response.quests, "Activities.WorldBoss.WorldBossSelectMain")
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.version = self.m_model.version;
    self.m_model:getNetData("train_challenge_recv_reward_all", params, callback)
end

return M
