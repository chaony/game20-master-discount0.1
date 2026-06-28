local M = class("GambleRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_open_id = self.m_params.open_id or 429
	self.m_version = self.m_params.version or 1
	local params = {}
	params.open_id = self.m_open_id
	params.version = self.m_version
	params.start = 1
	params.stop = 20
	self:getData("world_cup_ranks", params)
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	self.ranks_rewards = self:getRankRewards()
end

function M:getOpenID()
	return self.m_open_id
end

function M:getVersion()
	return self.m_version
end

function M:updateRankData(data)
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
 
--我的排行数据
function M:myRanks()
	-- local m_id = UserDataManager.user_data:getUid()
	-- for k,v in pairs(self.m_data.ranks) do
	-- 	if v.user.uid == m_id then
	-- 		return v
	-- 	end
	-- end
	local data = {}
	data.rank = self.m_data.self_rank or 0
	data.score = self.m_data.self_score or 0
	data.user = UserDataManager.user_data.user_status
	return data
end

--排行榜
function M:getRanks()
	return self.m_data.ranks or {}
end

function M:getRankNums()
	return #self.m_data.ranks, self.m_data.count
end

--奖励列表
function M:getRankRewards()
	local world_cup_rank_tab = ConfigManager:getCfgByName("world_cup_rank") or {}
	local world_cup_rank_tab_open_id = world_cup_rank_tab[self.m_open_id] or {}
	local world_cup_rank_tab_version = world_cup_rank_tab_open_id[self.m_version] or {}
	local new_tab = {}
	for k,v in pairs(world_cup_rank_tab_version) do
		if type(k) == "number" then 
			v.id = v.rank[1] or k
			v.last_id = v.rank[2] or 0
			table.insert(new_tab, v)
		end
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
	table.sort(new_tab, sortFunc)
	return new_tab
end

return M
