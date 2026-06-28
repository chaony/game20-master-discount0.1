local M = class("PeakRankRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.ranks_rewards = self:getRankRewards()
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
