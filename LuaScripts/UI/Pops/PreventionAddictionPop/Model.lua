local M = class("PreventionAddictionPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_on_ok_call = self.m_params.on_ok_call
	self.m_on_cancel_call = self.m_params.on_cancel_call
	self.m_ok_text = self.m_params.ok_text or Language:getTextByKey("new_str_0006")
	self.m_cancel_text = self.m_params.cancel_text or Language:getTextByKey("new_str_0007")
	self.m_text = self.m_params.text or ""
	self.m_title = self.m_params.title or Language:getTextByKey("new_str_0005")
	self.m_no_close_btn = self.m_params.no_close_btn
	self.m_tow_close_btn = self.m_params.tow_close_btn
	self.m_cost = self.m_params.cost
end

return M
