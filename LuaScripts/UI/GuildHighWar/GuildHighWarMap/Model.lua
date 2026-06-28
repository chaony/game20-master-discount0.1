local M = class("GuildHighWarMapModel", LikeOO.OODataBase)
function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_parent_model = self.m_params.parent_model
	self.guild_high_war_build = ConfigManager:getCfgByName("guild_high_war_build")
end

function M:updateData()
	
end

return M
