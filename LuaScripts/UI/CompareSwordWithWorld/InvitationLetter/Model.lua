local M = class("InvitationLetterModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("full_service_index")
end

function M:onEnter()
	self.m_invitation_index = self.m_params.invitation_index
	self.self_boss_rank = self.m_data.self_boss_damage_rank or 0 
end

function M:destroy()

	M.super.destroy(self)
end

return M