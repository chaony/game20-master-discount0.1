local M = class("RewardPreviewPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    self.m_show_rewards = self.m_params.show_rewards or {}
    self.m_openType =  self.m_params.openType -- openType == 1 不展示概率，展示自定义名字
end

function M:getShowRewards()
    return self.m_show_rewards or {}
end

return M
