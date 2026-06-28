local M = class("CommonUseItemPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_item_id = self.m_params.item_id
	self.m_cost_item_data = self.m_params.cost_item_data
	self.m_use_data = {RewardUtil.REWARD_TYPE_KEYS.ITEM, self.m_item_id, 1}
	local data = RewardUtil:getProcessRewardData(self.m_use_data)
	self.m_max_num = data.user_num
	self.m_num = self.m_max_num
end

function M:addUseNum(value)
	local new_count = self.m_num + value
	self.m_num = math.min(math.max(1,new_count),self:getMaxNum())
end

function M:getMaxNum()
	return self.m_max_num
end

function M:getNum()
	return self.m_num
end

function M:getUseItem()
    return self.m_use_data
end

return M
