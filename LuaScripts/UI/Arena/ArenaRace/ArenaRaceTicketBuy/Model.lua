local M = class("ArenaRaceTicketBuyModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_buy_mode = self.m_params.buy_mode or 0
	self.m_buy_times = self.m_params.buy_times or 0
	self.m_match_type = self.m_params.match_type or 0
	self.m_num = 1
	self.m_max_num = 99
	local cost = self:getCost()
	if cost[1] then
		local data = RewardUtil:getProcessRewardData(cost[1])
		self.m_max_num = math.floor(data.user_num/data.data_num)
	end
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

function M:getCost()
	if self.m_buy_mode == 1 then
		local cost = GameUtil:getRefreshCost(self.m_buy_times,10)
		return {cost}
	end
    local system_cost = ConfigManager:getCfgByName("system_cost")
    local system_cost_item = system_cost[8] or {}
    return system_cost_item.cost or {}
end

function M:getBuyItem()
	if self.m_buy_mode == 1 then
		local buy_count = ConfigManager:getCommonValueById(84, 0)
		return {RewardUtil.REWARD_TYPE_KEYS.ITEM, 1005, buy_count}
	end
    return {RewardUtil.REWARD_TYPE_KEYS.ITEM, 1033, 0}
end

return M
