local M = class("GachaHelpPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_pool_id = self.m_params.pool_id
end

return M
