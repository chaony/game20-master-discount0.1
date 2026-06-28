local M = class("SecretRewardTaskPopControl", LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refreshUI", nil, "GiftBag.SecretRewardPop")
        self:closeView()
    elseif msg == "get_reward_btn" then
        self:getTaskReward(data)
    elseif msg == "get_all_btn" then
        self:getAllScrollTask()
    elseif msg == "go_to" then
        static_rootControl:closeAllViewPop()
        local go_type = data or {}
        QuickOpenFuncUtil:openFunc(go_type)
    end
end

function M:getTaskReward(data)
    local function callback(response)
        if response then
            self.m_model:refreshData(response)
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("updateScrollData", response, "GiftBag.SecretRewardPop")
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.quest_id = data
    params.vsn = self.m_model.m_version
    self.m_model:getNetData("secret_receive_quest", params, callback, nil, true)
end

function M:getAllScrollTask()
    local function callback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model.m_quests = response.quests
        self:updateMsg("updateScrollData", response, "GiftBag.SecretRewardPop")
        self.m_view:refreshUI()
    end
    if self.m_model:checkCanQuick() == false then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("gf_str_0106"), delay_close = 2})
        return
    end
    self.m_model:getNetData("secret_receive_all_quest", {vsn = self.m_model.m_version}, callback)
end

return M
