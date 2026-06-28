local M = class("CommonSuccessPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_sound_name = self.m_params.sound_name or ""
	self.m_last_combat = self.m_params.last_combat or 0
	self.m_cur_combat = self.m_params.cur_combat or 0
	self.m_callback = self.m_params.callback
	
end

return M
