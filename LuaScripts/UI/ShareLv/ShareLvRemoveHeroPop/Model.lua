local M = class("ShareLvRemoveHeroPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_hero = self.m_params.data[2]
end

return M
