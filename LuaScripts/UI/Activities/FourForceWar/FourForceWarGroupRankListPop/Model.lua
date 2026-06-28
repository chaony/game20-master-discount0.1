local M = class("LiteratureGroupRankListPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version
	self.m_data = self.m_params.data
	self.m_force = self.m_params.force
	--Logger.log(self.m_data,"LiteratureGroupRankListPopModel data ===")
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	self.ranks_rewards = self:getRankRewards()
	if self.m_open_type == false then
		self.m_open_tab_index = 2
	end
	local enjoy_spring_force = ConfigManager:getCfgByName("enjoy_spring_force")
	self.enjoy_spring_force = enjoy_spring_force[self.m_version]
end

function M:getRanks()
	return self.m_data.ranks
end

function M:myRanks()
	for k,v in pairs(self.m_data.ranks) do
		if v.force == self.m_force then
			return v
		end
	end
	return {}
end


function M:getRankRewards()
	local reward_tab = ConfigManager:getCfgByName("enjoy_spring_force_rank")
	local version_reward_tab = reward_tab[self.m_version] or {}
	local new_tab = {}
	for k,v in pairs(version_reward_tab) do
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

function M:getEnjoySpringForceCfg(id)
	if self.enjoy_spring_force then
		return self.enjoy_spring_force[id]
	end
	return {}
end

function M:getActStatus()
	local active = UserDataManager:getActivesDataByOpenId(309)
	if active and active.open_status then
		return active.open_status
	end
	return 0
end

return M
