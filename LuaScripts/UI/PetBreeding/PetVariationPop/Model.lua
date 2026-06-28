local M = class("PetVariationPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_pet_oid = self.m_params.pet_oid
    local data, cfg = UserDataManager.pet_data:getPetDataById(self.m_pet_oid)
    self.m_variation_list = data.variation or {}
end

function M:getDesc()
    local desc = ""
    local variation_cfg = ConfigManager:getCfgByName("pet_variation")
    for k, v in ipairs(self.m_variation_list) do
        desc = desc .. Language:getTextByKey(variation_cfg[tonumber(v)].description) .. "\n"
    end
    return desc
end

return M
