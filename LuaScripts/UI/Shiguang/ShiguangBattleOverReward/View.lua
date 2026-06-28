local M = class("ShiguangBattleOverRewardView",LikeOO.OOPopBase)

M.m_uiName = "ShiGuang/ShiguangBattleOverReward"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("tips_text", "new_str_0243")
	self.m_item_node = self:findGameObject("item_node")
	self:refreshUI()
end

function M:refreshUI()
	local first_reward = self.m_model:getFirstReward()
	if first_reward then
		self.m_item_node.gameObject:SetActive(true)
		local data = RewardUtil:getProcessRewardData(first_reward)
		GameUtil:updateItemElementByData(self.m_item_node, data, false, true)
		self:setTextByLanKey("name_text", data.name)
	else
		self.m_item_node.gameObject:SetActive(false)
		self:setTextByLanKey("name_text", "???")
	end
end

return M