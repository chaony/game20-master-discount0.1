---@class PetBreedingInteractionModel: OODataBase
local M = class("PetBreedingInteractionModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_data = self.m_params
    if SceneManager:getCurSceneModel() then
        self.m_oid = SceneManager:getCurSceneModel().interactPetOid
    end
end

function M:updateData(data)
    if data then
        table.merge(self.m_data, data)
    end
end

return M