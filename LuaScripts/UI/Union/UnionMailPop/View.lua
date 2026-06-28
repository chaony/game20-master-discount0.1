local M = class("UnionMailView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionMailPop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("cancle_text", "new_str_0007")
	self:setTextByLanKey("ok_text", "new_str_0006")
	self:setTextByLanKey("common_title_text", "union_str_0026")
	self:setTextByLanKey("title_text", "union_str_0065")
	--self.title_input = self:findInputField("title_input")
	--self.title_input.placeholder.text = Language:getTextByKey("union_str_1047")
	--self.title_input.text = ""
	
	self.des_inputField = self:findInputField("des_inputField")
	self.des_inputField.placeholder.text = Language:getTextByKey("union_str_1048")
	self.des_inputField.text = ""

	self:refreshUI()
end

function M:refreshUI()

end

function M:getTitleText( )
	local text = Language:getTextByKey("union_str_0065")
	return text
end

function M:getDesText()
	local text = GameUtil:formatInputText(self.des_inputField.text)
	return text
end

return M