local M = class("NineActiveMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.nine_active_data = self.m_params.nine_active_data
	
end


return M
