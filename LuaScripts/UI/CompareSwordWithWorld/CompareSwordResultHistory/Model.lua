local M = class("CompareSwordResultHistoryModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	self.m_active = self.m_params.active or {}
end

function M:destroy()
	M.super.destroy(self)
end

return M