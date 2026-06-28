local M = class("GuildHighWarInvitePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	self.invite_data = self.m_params.invite_data or {}
	self.start_time = self.m_params.start_time
	self.end_time = self.m_params.end_time
end

return M
