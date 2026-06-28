local M = class("UnionNoticeModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_guild = self.m_params.guild or {}
end

return M
