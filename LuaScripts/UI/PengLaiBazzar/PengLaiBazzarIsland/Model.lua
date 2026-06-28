---@class PengLaiBazzarIslandModel: OODataBase
local M = class("PengLaiBazzarIslandModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("")
end

function M:onEnter()
    self:initData()
end

function M:initData()
    self.m_open_id = self.m_params.open_id or 350
end

return M