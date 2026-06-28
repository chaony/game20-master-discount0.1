local M = class("UnionBossRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("world_boss_get_ranks", {start = 1, stop = 50})
end

function M:onEnter()
	self.m_today_rank = {}
	self.m_yesterday_rank = {}
	self.m_day = 0
	self:updateRankData(self.m_data)

	local world_boss_reward = ConfigManager:getCfgByName("world_boss_reward")
	local table_key = {}
	for k,v in pairs(world_boss_reward) do
		table_key[#table_key + 1] = k
	end
	local function sort(data1, data2)
		return data1 < data2
	end
	table.sort(table_key,sort)
	self.rank_key = table_key
end

function M:resetRank()
	self.m_today_rank = {}
end

function M:updateRankData(data)
	if self.m_day == 1 then
		table.merge(self.m_yesterday_rank, data)
	else
		table.merge(self.m_today_rank, data)
	end
end

function M:setYesterDay()
	self.m_day = (self.m_day + 1)%2
	Logger.log(self.m_day,"m_day ===")
end

function M:getRankData()
	if self.m_day == 1 then
		return self.m_yesterday_rank.ranks or {}
	else
		return self.m_today_rank.ranks or {}
	end
end

function M:getSelfRankData()
	if self.m_day == 1 then
		return self.m_yesterday_rank.self_rank
	else
		return self.m_today_rank.self_rank
	end
end

function M:getDanData(rank)
	local world_boss_reward = ConfigManager:getCfgByName("world_boss_reward")
	local dan = rank
	if world_boss_reward[dan] == nil then
		local index = table.bisect(self.rank_key, dan)
		dan = self.rank_key[index]
	end
	return world_boss_reward[dan]
end

return M
