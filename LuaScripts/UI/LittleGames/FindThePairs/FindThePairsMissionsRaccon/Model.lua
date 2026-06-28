local M = class("FindThePairsMissionsRacconModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_group_id = self.m_params.group_id
	self.m_game_id = self.m_params.game_id
	self.m_open_type = self.m_params.open_type or ""
	self.m_open_id = self.m_params.open_id or 0
	self.m_mult = self.m_params.mult or false
end

return M
