local M = class("UnionHallModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params
end

function M:updateData(data)
	table.merge(self.m_data, data)
end

return M
