local M = class("CommonGetRedPacketPopView",LikeOO.OOPopBase)
--红包打开
M.m_uiName = "Pops/CommonGetRedPacketPop"
M.m_size_type = 2

function M:onEnter()	
	self.reward_grid = self:findGameObject("red_packet_btn")
	self:refreshUI()
end

function M:refreshUI()
	local rewards = RewardUtil:mergeRewardAndFormat(self.m_model.m_reward )
	local item = GameUtil:createItemElement(rewards[1], true)
	item.transform:SetParent(self.reward_grid.transform, false)
end

return M