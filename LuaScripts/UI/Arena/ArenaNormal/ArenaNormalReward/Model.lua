---@class ArenaNormalRewardModel:OODataBase
local M = class("ArenaNormalRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_tab_index = 1
	local data = self.m_params.data
	self.m_rank = data.rank or 999999999

	self.m_rank=self.m_rank==0 and 999999999 or self.m_rank
	self.m_next_reward_rank = -1
	self.m_cfg_name = self.m_params.cfg_name or "arena_reward"
	self.m_open_type = self.m_params.open_type or 0
	self:initRankReward()
	self.m_last_settlement_time = data.last_settlement_time or (UserDataManager:getServerTime() + 9*60*60*24)
	self.m_content = self.m_params.content
end

function M:initRankReward()
    local arena_reward = ConfigManager:getCfgByName(self.m_cfg_name)
	if self.m_params.rise_id then
		arena_reward=arena_reward[self.m_params.rise_id]
	end
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
		if self.m_params.rise_id then
			reward[1] = {cur_rewards = arena_reward_item.daily_awards}
			reward[2] = {cur_rewards = arena_reward_item.over_awards}
		else
			reward[1] = {cur_rewards = arena_reward_item.daily_rewards}
			reward[2] = {cur_rewards = arena_reward_item.season_rewards}
		end

		local next_reward_idx = reward_idx + 1
		if rank_ids[next_reward_idx] then -- 下一级奖励
			self.m_next_reward_rank = rank_ids[next_reward_idx]
			local next_arena_reward_item = arena_reward[rank_ids[next_reward_idx]]

			if self.m_params.rise_id then
				reward[1].next_rewards = next_arena_reward_item.daily_awards
				reward[2].next_rewards = next_arena_reward_item.over_awards
			else
				reward[1].next_rewards = next_arena_reward_item.daily_rewards
				reward[2].next_rewards = next_arena_reward_item.season_rewards
			end
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

function M:setTabIndex(index)
	self.m_tab_index = index
end

return M
