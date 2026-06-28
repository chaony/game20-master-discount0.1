local M = class("LiteratureRankListPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("enjoy_spring_rank_info", {start = 1, stop = 20})
end

function M:onEnter()
	--Logger.log(self.m_data,"enjoy_spring_rank_info ======")
	self.m_version = self.m_params.version
	self.m_force = self.m_params.force
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	self.ranks_rewards = self:getRankRewards()
	if self.m_open_type == false then
		self.m_open_tab_index = 2
	end
end

function M:getRanks()
	return self.m_data.ranks
end

function M:getRankNums()
	return #self.m_data.ranks
end

function M:getRankNums()
	return #self.m_data.ranks, self.m_data.count
end

function M:updateRank(data)
	if data then
		if data.ranks then
			for i=1, #data.ranks do
				table.insert(self.m_data.ranks, data.ranks[i])
			end
		end
		self.m_data.rank = data.rank or self.m_data.rank
		self.m_data.score = data.score or self.m_data.score
		self.m_data.count = data.count or self.m_data.count
	end
end

function M:myRanks()
	local m_id = UserDataManager.user_data:getUid()
	for k,v in pairs(self.m_data.ranks) do
		if v.user.uid == m_id then
			return v
		end
	end
	return {}
end

function M:getRankRewards()
	local reward_tab = ConfigManager:getCfgByName("enjoy_spring_rank")
	--Logger.log(reward_tab,"reward_tab =====")
	local version_reward_tab = reward_tab[self.m_version] or {}
	local group_reward_tab = version_reward_tab[self.m_force] or {}
	--Logger.log(group_reward_tab,"group_reward_tab =====")
	local new_tab = {}
	for k,v in pairs(group_reward_tab) do
		v.id = k
		table.insert(new_tab, v)
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getRankScope(index)
	if index > 1 then
		local last_rank = self.ranks_rewards[index-1]
		if last_rank then
			return last_rank.id + 1
		end
	end
	return 0
end


return M
