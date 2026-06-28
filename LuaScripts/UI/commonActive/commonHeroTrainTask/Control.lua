local M = class("commonHeroTrainTaskControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_callback then
            self.m_model.m_callback()
        end
        self:updateMsg("refresh_data", nil, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsBattle")
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
            self:updateMsg("update_data", self.m_model.m_data, self.m_model.refresh_ui_name)
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            self:updateMsg(99999)
            return
        end
        self.m_model:updateQuests(response)
        self:updateMsg("update_quest", response, self.m_model.refresh_ui_name)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data
    params.open_id = self.m_model.open_id
    params.version = self.m_model.version
    params.is_all = 0
    self.m_model:getNetData("common_train_challenge_recv_reward", params, callback)
end

--一键领取
function M:getRewardAll()
    local function callback(response)
        if response.update then
            self:updateMsg("update_data", self.m_model.m_data,self.m_model.refresh_ui_name)
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            self:updateMsg(99999)
            return
        end
        self.m_model:updateQuests(response)
        self:updateMsg("update_quest", response, self.m_model.refresh_ui_name)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.open_id = self.m_model.open_id
    params.version = self.m_model.version
    params.is_all = 1
    self.m_model:getNetData("common_train_challenge_recv_reward", params, callback)
end

return M
