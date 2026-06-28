local M = class("MysticSmartPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_list_data = self.m_params.evolution_list or {}
	self.m_evolution_type = self.m_params.evolution_type or 2 -- 1是智能进阶，2随机进阶
end

function M:getSelectData()
	local data = {}
	for i,v in ipairs(self.m_list_data) do
		data[tostring(v[1])] = {tostring(v[2]), tostring(v[3])}
	end
	return data
end

return M
