local M = class("GuidePlayerNameView",LikeOO.OOPopBase)

M.m_uiName = "Pops/GuidePlayerNamePop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("ok_text", "new_str_0006")
	self:setTextByLanKey("common_title_text", "new_str_0593")
	self:setTextByLanKey("random_btn_text", "new_str_0694")
	self:setTextByLanKey("text_hintText", "new_str_1057")
	self:setTextByLanKey("Placeholder", "com_input_tex")
	self.InputField = self:findInputField("InputField")
	UIUtil.addInputFieldListener(self.InputField.transform, handler(self,self.inputChanged))
	--self.InputField.placeholder.text = self.m_model.m_placeholder
	--self.InputField.text = self.m_model.m_text
	self.m_big_close_btn = self:findButton("big_close_btn")
	
	self:setObjectVisible("close_btn", false)

	self:refreshUI()
end

function M:inputChanged()
	local tempName = self:getNameFormat(self.InputField.text)
	self.InputField.text = tostring(tempName)
end



function M:refreshUI()
	self:setInputText()
end

function M:getText( )
	local text = GameUtil:formatInputText(self.InputField.text)
	return text
end

function M:setInputText()
	local name = self.m_model:randName()
	self.InputField.text = tostring(name)
end

-- 获取姓名(7个字符)
function M:getNameFormat(name)
	local nameCount = string.utf8len(name)
	local tempName = ""
	if nameCount > 7 then
		local nameList = string.cutText(name)
		for i = 1, 7 do
			tempName = tempName .. nameList[i]
		end
		return tempName
	end
	
	return name
end

return M