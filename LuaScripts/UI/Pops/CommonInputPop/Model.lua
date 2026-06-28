local M = class("CommonPopModel", LikeOO.OODataBase)

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
	self.m_tips = self.m_params.tips or ""
	self.m_title = self.m_params.title or Language:getTextByKey("new_str_0005")
	self.m_placeholder = self.m_params.placeholder or ""
	self.m_text = self.m_params.text or ""
	self.m_no_close_btn = self.m_params.no_close_btn
	self.m_cost = self.m_params.cost
	self.m_is_free = self.m_params.is_free
	self.m_character_limit = self.m_params.character_limit
	-- 1 修改名字， 0其他(走之前逻辑)
	self.m_popType = self.m_params.popType or 0
end

return M
