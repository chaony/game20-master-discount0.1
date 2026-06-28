local M = class("GuildHighWarSchedulePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()

end

function M:GetEndGuildRank()
	return self.end_guild_rank
end

function M:GetEndSelfRank()
	return self.end_self_rank
end

return M
