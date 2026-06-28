local M = class("HeroTeamRecommendPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999  then
        self:updateMsg("common_refresh", nil, "HeroBag")
        self:closeView()
    elseif msg == "open_btn" then
        self.m_model:setDesOpen(data)
        self.m_view:refreshUI()
        self.m_view.m_list_scroll:moveToCellIndex(data)
    elseif msg == "reward_click" then
        self:receivet(data)
    end
end

function M:receivet(id)
    local function receivetCallfunc(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
        RewardUtil:rewardTipsByData(response.reward)
    end
    self.m_model:getNetData("hero_formation_receive", {fmt_id = id}, receivetCallfunc)
end

return M