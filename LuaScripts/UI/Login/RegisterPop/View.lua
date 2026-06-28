local M = class("RegisterPopView",LikeOO.OOPopBase)

M.m_uiName = "Login/RegisterPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0366")
	self:setTextByLanKey("sign_up_btn_text", "new_str_0006")
	self:setTextByLanKey("cancle_btn_text", "new_str_0007")
	self:setTextByLanKey("name_input_label_text", "new_str_0367")
	self:setTextByLanKey("password_input_label_text", "new_str_0368")
	self:setTextByLanKey("password2_input_label_text", "new_str_0369")
	self.name_input = self:findInputField("name_input")
	Logger.log(self.name_input);
	self.password_input = self:findInputField("password_input")
	self.password2_input = self:findInputField("password2_input")
	self:refreshUI()
end

function M:refreshUI()
	
end

function M:getNameAndPassword( )
	return self.name_input.text, self.password_input.text, self.password2_input.text
end


return M