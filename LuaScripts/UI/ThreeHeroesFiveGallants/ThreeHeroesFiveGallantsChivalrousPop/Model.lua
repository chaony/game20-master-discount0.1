local M = class("ThreeHeroesFiveGallantsChivalrousPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self.m_select_index = self.m_params.select_index or 1
	self.hero_train_data = self.m_params.data
	self.m_version = self.m_params.version or 1
	self.m_camp = self.m_params.camp or 1
	self:getData("chivalrous_ranks",{vsn = self.m_version ,start = 1, stop = 50})
end

function M:onEnter() 
	self.rank_rewards = self:getCampRewards()
end

function M:getRanks()
	return self.m_data.ranks or {}
end

function M:netData(data, tag)
	table.merge(self.m_data, data or {})
end

function M:getMyRank()
	return 1, self.m_data.self_rank
end

function M:getMyScore()
	return self.m_data.score
end

--获取阵营奖励
function M:getCampRewards()
	local chivalrous_camp = ConfigManager:getCfgByName("chivalrous_camp")
	local camp = self.m_camp
	if self.m_camp == 0 then
		camp = 1
	end
	local method = chivalrous_camp[self.m_version][self.m_params.period][camp].method
	local tab = ConfigManager:getCfgByName("chivalrous_reward")
	if tab == nil then
		return {}
	end
	for i, v in pairs(tab[method][2]) do
		return v
	end
end

function M:getRankScope(index)
	if index > 1 then
		local ranks = self:getRankRewards()
		local last_rank = ranks[index-1]
		if last_rank then
			return last_rank.id + 1
		end
	end
	return 0
end

--获取对应阵营侠义值
function M:getCampRanks(camp_id)
	for i, v in pairs(self.m_data.camp_ranks) do
		if v.camp == camp_id then
			return v.score
		end
	end
	return 0
end

--获取排行奖励
function M:getRankReward(rank_id)
	local chivalrous_camp = ConfigManager:getCfgByName("chivalrous_camp")
	local camp = self.m_camp
	if self.m_camp == 0 then
		camp = 1
	end
	local method = chivalrous_camp[self.m_version][self.m_params.period][camp].method
	local chivalrous_reward = ConfigManager:getCfgByName("chivalrous_reward")
	local rewards = chivalrous_reward[method][1]
	for i, v in pairs(rewards) do
		if #v.parameter == 1 and rank_id == v.parameter[1] then --只有一个名次有奖励
			return v.reward
		elseif #v.parameter == 2 then
			if rank_id >= v.parameter[1] and rank_id <= v.parameter[2] then
				return v.reward
			end
		end
	end
	return {}
end

return M