local M = class("CommonPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonInputPop2"
M.m_size_type = 2

function M:onEnter()	
	self:setText("tips_text", self.m_model.m_tips)
	self:setText("cancle_text", self.m_model.m_cancel_text)
	self:setText("ok_text", self.m_model.m_ok_text)
	self:setText("common_title_text", self.m_model.m_title)
	self.InputField = self:findInputField("InputField")
	self.InputField.placeholder.text = self.m_model.m_placeholder
	self.InputField.text = self.m_model.m_text
	self.m_big_close_btn = self:findButton("big_close_btn")
	self:setTextByLanKey("Placeholder", self.m_model.m_placeholder)
	if self.m_model.m_no_close_btn then
		self.m_big_close_btn.enabled = false
		self:setObjectVisible("close_btn", false)
		--self:setObjectVisible("cancle_btn", false)
		self.m_ok_btn = self:findButton("ok_btn")
		UIUtil.setLocalPosition(self.m_ok_btn.transform, 0)
		self.m_cost_bg_img = self:findGameObject("cost_bg_img")
		UIUtil.setLocalPosition(self.m_cost_bg_img.transform, 0)
	end
	if self.m_model.m_cost then
		self:setObjectVisible("cost_bg_img", true)
		local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
		self:setImg(data.icon_name, data.atlas_name or "item_icon", "cost_img")
		local user_num = GameUtil:formatValueToString(data.user_num)
		local data_num = GameUtil:formatValueToString(data.data_num)
		if self.m_model.m_is_free then
			self:setTextByLanKey("cost_text", "new_str_0278")
		else
			self:setText("cost_text", data_num)
		end
	else
		self:setObjectVisible("cost_bg_img", false)
	end
	self:refreshUI()
	self.InputField.characterLimit = self.m_model.m_character_limit or 7
	UIUtil.addInputFieldListener(self.InputField.transform, handler(self,self.inputChanged))
end

function M:inputChanged()
	local tempName = self:getNameFormat(self.InputField.text)
	self.InputField.text = tostring(tempName)
end

function M:refreshUI()

end

function M:getText( )
	local text = GameUtil:formatInputText(self.InputField.text)
	return text
end

function M:setInputText(text)
	text = GameUtil:formatInputText(text)
	self.InputField.text = tostring(text)
end

-- 获取姓名(7个字符)
function M:getNameFormat(name)
	local nameCount = string.utf8len(name)
	local tempName = ""
	local maxLimit = self.m_model.m_character_limit or 7
	if nameCount > maxLimit then
		local nameList = string.cutText(name)
		for i = 1, maxLimit do
			tempName = tempName .. nameList[i]
		end
		return tempName
	end

	return name
end

return M