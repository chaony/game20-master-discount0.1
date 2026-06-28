local M = class("ThreeHeroesFiveGallantsHeroTrainRankListModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self.m_select_index = self.m_params.select_index or 1
	self.hero_train_data = self.m_params.data
	self:getData("chivalrous_rank_info", {version =self.m_params.version,start = 1,stop = 50})
end

function M:onEnter()
	self.rank_rewards = self:getRankRewards()
end

function M:getRanks()
	return self.m_data.ranks
end

function M:getMyRank()
	local rank_reward_tab = self:getRankRewards()
	return 1, self.m_data.rank
end

function M:getMyScore()
	return self.m_data.score
end

function M:getRankRewards()
	local chivalrous_camp = ConfigManager:getCfgByName("chivalrous_camp")
	local method = chivalrous_camp[1][self.m_params.camp][self.m_params.version].method
	local chivalrous_reward = ConfigManager:getCfgByName("chivalrous_reward")
	local rewards = chivalrous_reward[method][4]
	local new_tab = {}
	for k,v in pairs(rewards) do
		v.id = k
		table.insert( new_tab, v)
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getRankScope(index)
	if index > 1 then
		local ranks = self.rank_rewards
		local last_rank = ranks[index]
		if last_rank then
			return last_rank.parameter[1],last_rank.parameter[2]
		end
	end
	return 0
end

return M