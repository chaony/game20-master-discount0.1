local M = class("GamePanelPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_btn1_call = self.m_params.btn1_call
	self.m_btn2_call = self.m_params.btn2_call
	self.m_btn3_call = self.m_params.btn3_call
	self.m_btn1_text = self.m_params.btn1_text or Language:getTextByKey("game_panel_1")
	self.m_btn2_text = self.m_params.btn2_text or Language:getTextByKey("game_panel_2")
	self.m_btn3_text = self.m_params.btn3_text or Language:getTextByKey("game_panel_3")
	self.m_replay = self.m_params.replay
	self.m_mode = self.m_params.mode
end

function M:showRestartBtn()
	local show_btn = GlobalConfig.BATTLE_MODE_CFG[self.m_mode].show_restart_btn ~= false
	show_btn = show_btn and not self.m_replay
	return show_btn
end

return M
