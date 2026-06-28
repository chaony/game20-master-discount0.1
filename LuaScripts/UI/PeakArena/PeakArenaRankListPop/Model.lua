local M = class("PeakArenaRankListPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("select_top_arena_rank")
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	self.ranks_rewards = self:getRankRewards()
	self.m_open_type = self.m_params.open_type 
	if self.m_open_type == false then
		self.m_open_tab_index = 2
	end
end

function M:getRanks()
	return self.m_data.ranks
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
	local reward_tab = ConfigManager:getCfgByName("arena_reward_list")
	local peak_reward_tab = reward_tab[4]
	local new_tab = {}
	for k,v in pairs(peak_reward_tab) do
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
