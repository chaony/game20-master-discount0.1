local M = class("RewardIntelligenceView",LikeOO.OOPopBase)

M.m_uiName = "Reward/RewardIntelligencePop"
M.m_size_type = 2

function M:onEnter()

    self:setTextByLanKey("title_text", "bounty_str_0017")
    self:setTextByLanKey("name_text", "tid#BountyDes_9999")
    local subscribe = UserDataManager:getSubscribe()
    local state_lan = "bounty_str_0018"
    local state_color = Color(135/255,135/255,135/255,1)
    if subscribe ~= nil then
        if subscribe.bounty_auto_etime == -1 then
            state_lan = "bounty_str_0019"
            state_color = Color(61/255,116/255,13/255,1)
        end
    end
    self:setTextByLanKey("jh_text", state_lan)
    self:setTextColor("jh_text", state_color)
end

return M