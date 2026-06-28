local M = class("TransitionPageModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_view_name = self.m_params.open_view_name
	self.m_open_view_params = self.m_params.open_view_params
end

return M
