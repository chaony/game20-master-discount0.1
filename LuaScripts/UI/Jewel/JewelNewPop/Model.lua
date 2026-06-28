local M = class("JewelNewPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_jewel_id = self.m_params.id
	self.m_callback = self.m_params.callback or nil
end

return M