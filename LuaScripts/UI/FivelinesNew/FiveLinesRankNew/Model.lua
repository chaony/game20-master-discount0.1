local M = class("FiveLinesRankNewModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
end


function M:initData(c_b)
	if self.m_sel_tab_index == 1 and self.m_rank_data == nil then
		local params = { sort = 4, start = 1, stop = 50 }
		self:getNetData("rank_enter", params, c_b, nil, true)
	elseif self.m_sel_tab_index == 2 and self.m_friend_data == nil then 	
		local floor = self.m_rank_data.score
		self:getNetData("filv_combat_data", {floor_id = floor } , c_b, nil, true)
	else
		c_b()
	end
end


function M:getOwnRankData()
	local rank = self.m_rank_data.rank or 0
	local score = self.m_rank_data.score or 0
	local data = {rank = rank, score = score, time = 0}
	local uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	local name = UserDataManager.user_data:getUserStatusDataByKey("name")
	local level = UserDataManager.user_data:getUserStatusDataByKey("level")
	local vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
	local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
	data.user = {uid = uid, name = name, level = level, vip = vip, avatar = avatar}
	return data
end

function M:getRankData()
	local ranks = self.m_rank_data.ranks or {}
	return ranks
end

function M:getCombatData()
	local combat_data = {}
	table.insert( combat_data, self.m_friend_data.min_server)
	return combat_data
end

function M:getDataByFloor(index)
	local tower_tab = ConfigManager:getCfgByName("five_element_tower")
	local elem_list = tower_tab[self.m_rank_data.score]["element_list"]
	return elem_list[index]
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "rank_enter" then
		self.m_rank_data = data --排行
	elseif tag == "filv_combat_data" then
		self.m_friend_data = data.combat_data --详情
	elseif tag == "receive_rewards" then
		self.receive_data = data.tower_data	
	end
end

return M
