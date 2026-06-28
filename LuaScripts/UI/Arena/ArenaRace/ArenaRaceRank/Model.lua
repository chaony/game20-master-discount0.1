local M = class("ArenaRaceRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_open_type =  self.m_params.open_type or 0
	self.m_sel_tab_index = 1
	if self.m_open_type == 2 then
		self:getData("race_arena_season_select_arena_rank", {start = 1, stop = 50, match_type = self.m_open_type})
	--联赛争锋
	elseif self.m_open_type == 5 then
		self:getData("rise_arena_rank_info", {start = 1, stop = 50})
		self.team_num=self.m_params.team_num
	else
		self:getData("race_arena_select_arena_rank", {start = 1, stop = 50, match_type = self.m_open_type})
	end
end

function M:onEnter()
	self.m_rank_data = {}
	local data=self.m_data
	self:updateRankData(self.m_sel_tab_index, self.m_data.ranks)
end

function M:updateRankData(index, rank_data)
	if not(self.m_rank_data[index]) then
		self.m_rank_data[index] = {}
	end
	self.m_rank_data[index] = rank_data
end

function M:getDataByIndex(index)
	return self.m_rank_data[index] and self.m_rank_data[index] or {}
end

function M:getRankData()
	local ranks = self:getDataByIndex(self.m_sel_tab_index)
	return ranks
end

function M:getMatchTypeByIndex(index)
	local match_type = 0
	if self.m_open_type == 0 then
		return 0
	end
	if index == 1 then
		match_type = self.m_open_type == 2 and 2 or 1 
	elseif index == 2 then
		match_type = self.m_open_type == 2 and 1 or 0
	elseif index == 3 then
		match_type = 0
	end 
	return match_type 
end

return M
