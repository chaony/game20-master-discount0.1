---@class MysticReplacePopModel:OODataBase
local M=class("MysticReplacePopModel",LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_mystic_id=self.m_params.id
end

function M:getMysticData()
    local cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_mystic_id)
    return cfg
end

return M