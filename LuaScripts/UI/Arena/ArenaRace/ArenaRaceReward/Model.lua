local M = class("ArenaRaceRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	local data = self.m_params.data
	self.m_rank = data.rank or 999999999
	self.m_next_reward_rank = -1
	self:initRankReward()
	self.m_last_settlement_time = data.last_settlement_time or (UserDataManager:getServerTime() + 9*60*60*24)
end

function M:initRankReward()
    local arena_reward = ConfigManager:getCfgByName("race_arena_reward")
	local rank_ids = {}
	for k, v in pairs(arena_reward) do
		table.insert(rank_ids, k)
	end
	table.sort(rank_ids, function(data1, data2)
		return data1 > data2
	end)
	local reward_idx = -1
	for k,v in ipairs(rank_ids) do
		if self.m_rank <= v then
			reward_idx = k
		end
	end
	local reward = {}
	if rank_ids[reward_idx] then
		local arena_reward_item = arena_reward[rank_ids[reward_idx]]
		reward[1] = {cur_rewards = arena_reward_item.daily_rewards}
		reward[2] = {cur_rewards = arena_reward_item.season_rewards}
		local next_reward_idx = reward_idx + 1
		if rank_ids[next_reward_idx] then -- 下一级奖励
			self.m_next_reward_rank = rank_ids[next_reward_idx]
			local next_arena_reward_item = arena_reward[rank_ids[next_reward_idx]]
			reward[1].next_rewards = next_arena_reward_item.daily_rewards
			reward[2].next_rewards = next_arena_reward_item.season_rewards
		end
	end

	self.m_rank_reward = reward
end

function M:getRankReward()
	return self.m_rank_reward
end

function M:getNextRewardRank()
	return math.max(self.m_next_reward_rank, 1)
end

function M:getRemainingTime()
	local end_time = self.m_last_settlement_time or 0
	return end_time - UserDataManager:getServerTime()
end

return M
