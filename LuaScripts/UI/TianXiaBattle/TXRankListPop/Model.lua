---@class TXRankListPopModel:OODataBase
local M = class("TXRankListPopModel", LikeOO.OODataBase)

local __max_rank_count = 100
function M:onCreate()
	M.super.onCreate(self)
	self.m_cur_rank_sort = self.m_params.sort or 1 -- 排行榜的类型 1：帮会战，2：苗疆觅宝，3：天下演武，4：秘籍，5：装备，6：法宝
	local params = {}
	params.is_cross = self.m_params.is_cross or 0
	params.sort = self.m_cur_rank_sort or 1
	params.start = 1
	params.stop = 10
	self:getData("world_rank_info", params)
end

function M:onEnter()
	self.m_total_rank_data = self.m_params.total_rank_data or {} -- 所有排行榜的数据，用来判读排行榜解没解锁
	--Logger.logWarningAlways(table.nums(self.m_total_rank_data)," x=c=x=cx=c=x=======")
	self.m_my_rank_tab = {} --自己的排名数据
	self.m_ohter_ranks_tab = {} -- 排行榜数据
	self.m_top3_ranks_tab = {} -- 排行榜数据
	self.m_count_tab = {} --各个排行榜的人数
	self:initRankData()
end

function M:initRankData(response)
	if response then
		self.m_data = response
		self.m_isShowRank = (response.gvg_rank_name == "guild_lv")
	end
	if not(self.m_my_rank_tab[tostring(self.m_cur_rank_sort)]) then
		self.m_my_rank_tab[tostring(self.m_cur_rank_sort)] = {rank = self.m_data.rank, score = self.m_data.score}
		self.m_count_tab[tostring(self.m_cur_rank_sort)] = self.m_data.count
		self.m_top3_ranks_tab[tostring(self.m_cur_rank_sort)] = {}
		for i = 1, 3 do
			if self.m_data.ranks[1] then
				self.m_top3_ranks_tab[tostring(self.m_cur_rank_sort)][i] = self.m_data.ranks[1]
				table.remove(self.m_data.ranks, 1)
			end
		end
		self.m_ohter_ranks_tab[tostring(self.m_cur_rank_sort)] = self.m_data.ranks or {}
		self.m_isShowRank = (self.m_data.gvg_rank_name == "guild_lv")
	end
end

function M:getLoadIndex()
	local max_rank_count = math.min(self:getCurRankCount(), __max_rank_count)
	local cur_rank_nums = table.nums(self:getCurTop3RankData()) + table.nums(self:getCurOtherRankData())
	local start_pos, end_pos = 0, 0
	if cur_rank_nums + 10 <= max_rank_count then
		start_pos = cur_rank_nums + 1
		end_pos = cur_rank_nums + 10
	elseif max_rank_count - cur_rank_nums > 0 then
		start_pos = cur_rank_nums + 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos
end

function M:getNextSort(direction)
	local next_sort = self.m_cur_rank_sort
	local limit_value = direction == -1 and 0 or table.nums(self.m_total_rank_data)
	local start_sort = math.min(self.m_cur_rank_sort + direction, table.nums(self.m_total_rank_data))
	if self.m_cur_rank_sort == table.nums(self.m_total_rank_data) and direction == 1 then
		return false
	end
	for i = start_sort, limit_value, direction do
		if self.m_total_rank_data[tostring(i)] and next(self.m_total_rank_data[tostring(i)]) then
			return i
		end
	end
	return false
end

function M:getCurRankCount()
	return self.m_count_tab[tostring(self.m_cur_rank_sort)]
end

function M:getCurMyRankData()
	return self.m_my_rank_tab[tostring(self.m_cur_rank_sort)]
end

function M:getCurOtherRankData()
	return self.m_ohter_ranks_tab[tostring(self.m_cur_rank_sort)]
end

function M:getCurTop3RankData()
	return self.m_top3_ranks_tab[tostring(self.m_cur_rank_sort)]
end

function M:setRankSort(rank_sort)
	self.m_cur_rank_sort = rank_sort
end

function M:insertRankData(new_rank_data)
	for i = 1, #new_rank_data do
		table.insert(self.m_ohter_ranks_tab[tostring(self.m_cur_rank_sort)], new_rank_data[i])
	end
end

function M:isHaveRankDataBySort(rank_sort)
	if not(self.m_my_rank_tab[tostring(self.m_cur_rank_sort)]) then
		return false
	else
		return true
	end
end

return M
