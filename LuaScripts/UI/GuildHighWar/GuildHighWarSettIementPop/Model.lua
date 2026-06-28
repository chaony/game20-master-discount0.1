local M = class("GuildHighWarSettlementPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	--Logger.logError(self.m_data, "----------巅峰--")
	self.m_current_index = 1
	self.end_guild_rank  = self.m_params.end_guild_rank or nil
	self.end_self_rank  = self.m_params.end_self_rank or nil
	self.big_stage = self.m_params.big_stage or 4
	self.m_guild_info = self.m_params.m_guild_info
	self.playoff_type = self.m_params.playoff_type
end

function M:GetEndGuildRank()
	return self.end_guild_rank
end

function M:GetEndSelfRank()
	return self.end_self_rank
end

return M
