local M = class("DepositoryGropSkillTipsModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_id = self.m_params.id
end



return M
