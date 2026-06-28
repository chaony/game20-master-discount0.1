local M = class("VedioPlayerPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	local vedio_name = self.m_params.vedio_name or  "gacha.mp4"
	self.m_vedio_path = "mp4/" .. vedio_name
	self.m_no_close_btn = self.m_params.no_close_btn 
	self.m_close_btn_type = self.m_params.close_btn_type or 0
	self.m_delay = self.m_params.delay or 0
	self.m_close_btn_delay = self.m_params.close_btn_delay or 0
	self.m_close_view_flag = self.m_params.close_view_flag
end

return M
