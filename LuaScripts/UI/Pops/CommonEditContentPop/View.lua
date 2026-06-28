local M = class("CommonPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonEditContentPop"
M.m_size_type = 2

function M:onEnter()	
	self:setText("cancle_text", self.m_model.m_cancel_text)
	self:setText("ok_text", self.m_model.m_ok_text)
	self:setText("common_title_text", self.m_model.m_title)
	self.InputField = self:findInputField("InputField")
	self.InputField.placeholder.text = self.m_model.m_placeholder
	self.InputField.text = self.m_model.m_text
	self.m_big_close_btn = self:findButton("big_close_btn")
	if self.m_model.m_no_close_btn then
		self.m_big_close_btn.enabled = false
		self:setObjectVisible("close_btn", false)
		self:setObjectVisible("cancle_btn", false)
		self.m_ok_btn = self:findButton("ok_btn")
		UIUtil.setLocalPosition(self.m_ok_btn.transform, 0)
	end
	self:refreshUI()
end

function M:refreshUI()

end

function M:getText()
	return self.InputField.text
end

return M