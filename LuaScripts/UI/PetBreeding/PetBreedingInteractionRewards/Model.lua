local M = class("PetBreedingInteractionRewardsModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_rewards = ConfigManager:getCommonValueById(741, {})
end

return M