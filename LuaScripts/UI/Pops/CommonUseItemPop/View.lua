local M = class("CommonUseItemPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonUseItemPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0005")
	self:setTextByLanKey("cancle_text", "new_str_0007")
	self:setTextByLanKey("ok_text", "new_str_0048")
	self:setTextByLanKey("cost_title_text", "new_str_0498")
	self.m_item_node = self:findGameObject("item_node")
	self.find_input = self:findInputField("user_input_field")
	UIUtil.addInputFieldListener(self:findGameObject("user_input_field").transform, handler(self,self.inputChanged))
	self:refreshUI()
end

function M:refreshUI()
    self:updateUseNum()
end

function M:updateUseNum()
	local reward_data = RewardUtil:getProcessRewardData(self.m_model:getUseItem())
	self:setTextByLanKey("title_text", "new_str_0253", tostring(reward_data.name))
	GameUtil:updateItemElementByData(self.m_item_node, reward_data, true, true)
	self:setTextByLanKey("tips_text", "new_str_0552", self.m_model.m_cost_item_data.name, reward_data.name, self.m_model.m_cost_item_data.name)
	self:setSearchText(self.m_model.m_num)
end

function M:getSearchText()
	return self.find_input.text
end

function M:setSearchText(num)
	self.find_input.text = num
end

function M:inputChanged()
	local num = self:getSearchText()
	if num and num ~= "" and type(tonumber(num)) == "number" then
		if tonumber(num) > tonumber(self.m_model.m_max_num) then
			self:setSearchText(tonumber(self.m_model.m_max_num))
		end
		self.m_model.m_num = math.min(tonumber(self.m_model.m_max_num), tonumber(num))
	end
end

return M