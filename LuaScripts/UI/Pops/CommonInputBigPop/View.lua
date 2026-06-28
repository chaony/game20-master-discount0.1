local M = class("CommonInputBigPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonInputBigPop"
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
	--self.InputField.characterLimit = self.m_model.m_character_limit or 7
end

function M:refreshUI()

end

function M:getText( )
	return self.InputField.text
end

function M:setInputText(text)
	self.InputField.text = tostring(text)
end

return M