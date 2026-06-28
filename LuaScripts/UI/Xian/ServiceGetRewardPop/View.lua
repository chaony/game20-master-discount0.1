local M = class("ServiceGetRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "Xian/ServiceGetRewardPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:setTextByLanKey("center_count", self.m_model.m_reard_data.data.dialogue)
    self.reward_grid = self:findGameObject("reward_node")
	self:setTextByLanKey("get_reward_text", "new_str_0056")
    self.m_item = {}
	local num = #self.m_model.m_rewards
	for i = 1, num do
		local data = self.m_model.m_rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(self.reward_grid.transform, false)
		UIUtil.setScale(item.transform, 0.9)
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		self.m_item[i] = item
	end
	self.num = num
end

return M