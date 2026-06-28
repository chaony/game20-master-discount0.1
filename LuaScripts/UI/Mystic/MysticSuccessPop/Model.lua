local M = class("AdvancedSuccessPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_hero = self.m_params.hero
end

return M
