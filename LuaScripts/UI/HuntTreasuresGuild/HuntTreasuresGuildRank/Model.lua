local M = class("HuntTreasuresGuildRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	local params = {}
	params.is_cross = 1 --0 本服，1 跨服，
	params.ver = self.m_params.version or 1
	params.sort = 1
	params.start = 1
	params.stop = 20
	self:getData("active_mining_rank", params)
end

function M:onEnter()
	self.m_version = self.m_params.version
	self.m_sel_tab_index = 0
	self.m_vsn = self.m_params.version or 1
	self.m_inside_rank_data = {}
	self.ranks_rewards = self:getRankRewards()
end

--我的排行
function M:getMyRankData()
	local data = {}
	data.rank = self.m_data.rank or 0
	data.score = self.m_data.score or 0
	data.user = UserDataManager.user_data.user_status
	return data
end

--排行
function M:getRankData()
	return self.m_data.ranks or {}
end

--内部排行
function M:initInsideRankData(data)
	table.merge(self.m_inside_rank_data, data)
end

function M:getMyInsideRankData()
	local data = {}
	data.rank = self.m_inside_rank_data.rank or 0
	data.score = self.m_inside_rank_data.score or 0
	data.time = self.m_inside_rank_data.time or 0
	data.user = UserDataManager.user_data.user_status
	return data
end

function M:getInsideRankData()
	return self.m_inside_rank_data.ranks or {}
end

--奖励
function M:getRankRewards()
	local reward_data_tab = ConfigManager:getCfgByName("active_mining_rank") or {}
	local reward_data_season_tab = reward_data_tab[self.m_version] or {}
	local reward_data = {}
	for k,v in pairs(reward_data_season_tab) do
		if type(k) == "number" then
			v.id = k
			table.insert(reward_data, v)
		end
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
	end
	table.sort(reward_data, sortFunc)
	return reward_data
end

--帮派探索进度奖励限制标题数据
function M:getGuildExploreRewardLimit()
	local common = ConfigManager:getCfgByName("common")
	local value = 0
	if common[667] and common[667].value then
		value = common[667].value or 0
	end
	return value
end

return M
