local M = class("GifLimitExchangeTaskPopControl", LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refreshUI", nil, "GiftBag")
        self:closeView()
    elseif msg == "get_reward_btn" then
        self:getTaskReward(data)
    elseif msg == "go_to" then
        static_rootControl:closeAllViewPop()
        local go_type = data or {}
        QuickOpenFuncUtil:openFunc(go_type)
    end
end

function M:getTaskReward(data)
    local function callback(response)
        self.m_model:refreshData(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:updateMsg("updateLimitExchange", response, "GiftBag")
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data
    params.version = self.m_model.m_version
    self.m_model:getNetData("receive_exchange_quest", params, callback)
end


return M
