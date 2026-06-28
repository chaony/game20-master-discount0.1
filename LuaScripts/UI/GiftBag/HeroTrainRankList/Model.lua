local M = class("HeroTrainRankListModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self.m_select_index = self.m_params.select_index or 1
	self.hero_train_data = self.m_params.data
	self:getData("train_rank", {version = self.hero_train_data.version})
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
	-- if rank_cfg then
	-- 	if rank_cfg.sort == 1 then
			
	-- 	else
	-- 		return 2, rank_cfg.param[1] or 0
	-- 	end
	-- end
	--return 0,0
end

function M:getMyScore()
	return self.m_data.score
end

function M:getRankRewards()
	local tab = ConfigManager:getCfgByName("train_challenge_ranking")
	local new_tab = {}
	for k,v in pairs(tab) do
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
		local ranks = self:getRankRewards()
		local last_rank = ranks[index-1]
		if last_rank then
			return last_rank.id + 1
		end
	end
	return 0
end

return M