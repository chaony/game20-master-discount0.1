local M = class("ArenaNormalTicketBuyView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaNormal/ArenaNormalTicketBuy"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0223")
	self:setTextByLanKey("cancle_text", "new_str_0007")
	self:setTextByLanKey("ok_text", "new_str_0037")
	self:setTextByLanKey("cost_title_text", "new_str_0498")
	self.m_item_node = self:findGameObject("item_node")
	self:setObjectVisible("add_node", self.m_model.m_buy_mode == 0)
	self:refreshUI()
end

function M:refreshUI()
    self:updateUseNum()
end

function M:updateUseNum()
    local cost = self.m_model:getCost()
    if cost[1] then-- 购买
		self:setObjectVisible("cost_node", true)
		local num = self.m_model:getNum()
		local data = RewardUtil:getProcessRewardData(cost[1])
		local data_num = GameUtil:formatValueToString(data.data_num*num)
		local cost_num_text = self:setText("cost_num_text", data_num)
		if data.data_num > data.user_num then
			cost_num_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
		else
			cost_num_text.color = GlobalConfig.COMMON_COLLOR.COMMON_14
		end
		self:setImg(data.icon_name, "item_icon", "cost_icon")
		self:setTextByLanKey("num_text", tostring(num))
		local reward_data = RewardUtil:getProcessRewardData(self.m_model:getBuyItem())
		self:setTextByLanKey("title_text", "new_str_0253", tostring(reward_data.name))
		local ui_element = GameUtil:updateItemElementByData(self.m_item_node, reward_data, self.m_model.m_buy_mode == 1, false)
    else
		self:setObjectVisible("cost_node", false)
	end
end

return M