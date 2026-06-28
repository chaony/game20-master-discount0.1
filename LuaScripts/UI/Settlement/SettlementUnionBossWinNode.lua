--- 竞技场结算 成功
local M = class("SettlementUnionBossWinNodeNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementUnionBossWinNode"

function M:onEnter()
    local max_damage = self.m_model.m_damage
    self:setText("max_value_text", max_damage)
	self.reward_grid = self:findGameObject("reward_grid")
    self:showReward()
end

--[[
    奖励列表
]]
function M:showReward()
	self.m_item = {}
    local num = math.min(10,#self.m_model.m_rewards)
	for i = 1, num do
		local data = self.m_model.m_rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(self.reward_grid.transform, false)
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		UIUtil.setOpacity(item.transform, 0)
		self.m_item[i] = item
    end
    self.m_control:setOnceTimer(1,handler(self,self.revealItem))
	self.num = num
end

function M:revealItem()
    for k,v in pairs(self.m_item) do
        UIUtil.setOpacity(v.transform, 1)
    end
end

return M