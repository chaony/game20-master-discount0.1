local M = class("LiteratureRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params
	local enjoy_spring_force = ConfigManager:getCfgByName("enjoy_spring_force")
	Logger.log(enjoy_spring_force,"enjoy_spring_force ==== ")
	self.enjoy_spring_force = enjoy_spring_force[self.m_data.version]
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
