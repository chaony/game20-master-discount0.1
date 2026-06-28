local M = class("MysticUpgradePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.up_type = 1
	local id = 0
	for i,v in ipairs(self.m_params) do
		local data, cfg = UserDataManager.mystic_data:getMysticDataById(v)
		if id == 0 then
			id = data.id
		else
			if id ~= data.id then
				self.up_type = 2
				break
			end
		end
	end
end

function M:getEvolutionData()
	local  param = {}
	param[self.m_params[1]] = {self.m_params[2], self.m_params[3]}
	return param
end

return M
