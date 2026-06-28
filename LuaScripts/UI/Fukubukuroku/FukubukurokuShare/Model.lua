---@class FukubukurokuShareModel: OODataBase
local M = class("FukubukurokuMainModel", LikeOO.OODataBase)


function M:onCreate()
    self.open_id = self.m_params.open_id or 412
    self.version = self.m_params.version or 1
    self.can_share = self.m_params.can_share or 0
    self:getData()
end


function M:onEnter()
end



return M
