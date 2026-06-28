local M = class("BossFightDamageRankListModel", LikeOO.OODataBase)

local rankOffset = 10

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_total_rank_list = {
		{ battle_id = 0 , count = -1 , ranks = {}} ,
		{ battle_id = self.m_params.selectData.battle_id , count = -1 , ranks = {}} ,
	}
	self.m_cur_tab_index = 1
	self:getData("full_service_get_boss_damage_rank", {battle_id = 0 , start = 1, stop = rankOffset})  
end

function M:onEnter()
	self:initData()
end

function M:initData(data)  
	self.m_data = data or self.m_data
	self.m_total_rank_list[self.m_cur_tab_index].ranks = {}
	self.m_total_rank_list[self.m_cur_tab_index].count = self.m_data.count  
	self:insertRankData(self.m_data.ranks)
end

function M:requireNetData(battleId)
	local callback = function(response)
		self:initData(response)
	end
	local start_pos , end_pos = self:getLoadIndex()
	if start_pos == 0 and end_pos == 0 then return end
	self:getNetData("full_service_get_boss_damage_rank",{
		battle_id  = battleId,
		start = start_pos ,
		stop = end_pos ,}, callback)
end

function M:insertRankData(new_rank_data)
	for i = 1, #new_rank_data do 
		table.insert(self.m_total_rank_list[self.m_cur_tab_index].ranks , new_rank_data[i])	
	end
end


function M:getLoadIndex()	
	local max_rank_count = self.m_total_rank_list[self.m_cur_tab_index].count
	local cur_rank_nums = table.nums(self:getRankData()) 
	local start_pos, end_pos = 0, 0 
	if cur_rank_nums + rankOffset <= max_rank_count then 
		start_pos = cur_rank_nums + 1
		end_pos = cur_rank_nums + rankOffset
	elseif max_rank_count - cur_rank_nums > 0 then 
		start_pos = cur_rank_nums + 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos 
end

function M:getRankData()
	local rankData = self.m_total_rank_list[self.m_cur_tab_index].ranks
	return rankData 
end

function M:getOwnRankData() 
	local userData = UserDataManager.user_data:getOwnRankData({ rank = self.m_data.self_rank, score = self.m_data.self_score })
	return userData
end

function M:getOwnFightRankData() 
	local userData = UserDataManager.user_data:getOwnRankData({ rank = self.m_data.self_rank, score = self.m_data.self_score  })
	local own = self:getOwnRankData()
	local server_Name = UserDataManager.server_data:getServerName()
	userData.user.flag = self.m_flag or 0
	userData.user.server_name = server_Name
	return userData
end

function M:getCurRankDataByIndex(index)
	local ranks = self.m_total_rank_list[self.m_cur_tab_index].ranks or {}
	return ranks[index]
end

--
--function M:getRankRedPointById(id)
--	local red_dot =  {}
--	local value = red_dot[tostring(id)] or 0
--	return value == 1
--end

return M
