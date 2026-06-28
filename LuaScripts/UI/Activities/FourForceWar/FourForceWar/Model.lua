---@class FourForceWarModel:OODataBase
local M = class("FourForceWarModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params
	local enjoy_spring_force = ConfigManager:getCfgByName("enjoy_spring_force")
	Logger.log(enjoy_spring_force,"enjoy_spring_force ==== ")
	local force_cfg = enjoy_spring_force[self.m_data.version]
	self.enjoy_spring_force = {}
	for i,v in pairs(force_cfg or {}) do
		local people = self:getGroupPeopleCount(i)
		table.insert(self.enjoy_spring_force, {id = i, cfg = v, people = people})
	end
	table.sort(self.enjoy_spring_force, function(a, b) return a.people < b.people end)
end

function M:getLiteratureCfg(index)
	if self.enjoy_spring_force then
		return self.enjoy_spring_force[index]
	end
end

function M:getGroupPeopleCount(index)
	return self.m_data.guild_number[tostring(index)] or 0
end

return M
