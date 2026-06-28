local M = class("GuildHighWarMachineMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("guild_high_war_talent_index")
end

function M:onEnter()
	--Logger.logError(self.m_data, "----------巅峰--")
	self.guild_data = self.m_data.guild_data
	self.user_data_page_2 = self.m_data.user_data_page_2
	self.user_data_page_3 = self.m_data.user_data_page_3
end

function M:InitData(data)
	self.guild_data = data.guild_data
	self.user_data_page_2 = data.user_data_page_2
	self.user_data_page_3 = data.user_data_page_3
end

return M
