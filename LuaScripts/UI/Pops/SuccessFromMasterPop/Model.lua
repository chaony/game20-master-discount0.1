local M = class("CommonPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_status = self.m_params.status --
	self.m_info = self.m_params.info
end

return M
