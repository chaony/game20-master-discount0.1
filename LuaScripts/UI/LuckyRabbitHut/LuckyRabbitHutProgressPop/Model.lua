local M = class("LuckyRabbitHutProgressPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	
	self.m_version = self.m_params.version or 1
	self.m_total_times = self.m_params.total_times or 0
	
	self.mileage_cfg = ConfigManager:getCfgByName("rabbit_mileage")
	self:getData("")
end

function M:getMileage()
	local result = {}
	result = self.mileage_cfg[self.m_version]
	return result
end

function M:onEnter()
	self.m_active = self.m_params.active or {}
end

function M:getUnlockIndex()
	local result = 1
	local mileage_cfg = self:getMileage()
	for i, v in ipairs(mileage_cfg) do
		if self.m_total_times >= v.times then
			result = i
		end 
	end
	return result
end

function M:destroy()
	M.super.destroy(self)
end

return M