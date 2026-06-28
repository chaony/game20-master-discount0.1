local M = class("CommonItemTipsPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_normal_data = self.m_params.data
	self.m_target_obj = self.m_params.target_obj
end

return M
