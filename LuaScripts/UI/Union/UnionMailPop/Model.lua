local M = class("UnionMailModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_guild = self.m_params.guild or {}
	self.m_target_uid = self.m_params.target_uid or -1
end

return M
