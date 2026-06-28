local M = class("HuashanSwordTop3Model", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("arena_mountain_hua_arena_index")
end

function M:onEnter()
	self.m_version = self.m_data.version or 1
	self.m_cur_day = self.m_data.active_day or 1
	self.m_total_day = self.m_data.active_day or 1
	self.m_total_rank = {}
	self:updateTotalRank(self.m_data.ranks_top)
end

function M:setCurDay(day)
	self.m_cur_day = day
end

function M:isCurDay()
	return self.m_cur_day == self.m_total_day
end

function M:getCurStartTs()
	if self.m_data and self.m_data.today_start_ts then
		local offset_day = self.m_total_day - self.m_cur_day
		local offset_seconds = offset_day * 24 * 60 * 60
		local ts = self.m_data.today_start_ts - offset_seconds
		return ts
	end
	return UserDataManager:getServerTime()
end

function M:getDayByDirection(is_left) 
	local day = self.m_cur_day + (is_left * 1)
	day = math.max(1, day)
	day = math.min(self.m_total_day, day)
	return day
end

function M:isNeedRequest(day)
	if not(self.m_total_rank[day]) and day ~= self.m_cur_day then
		return true
	end
	return false
end

function M:updateTotalRank(rank_data)
	if rank_data and next(rank_data) then
		if not(self.m_total_rank[self.m_cur_day]) then
			self.m_total_rank[self.m_cur_day] = rank_data
		else
			table.merge(self.m_total_rank[self.m_cur_day], rank_data)
		end
		self:sortRanksTops(self.m_total_rank[self.m_cur_day])
	end
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self:sortRanksTops()
end

function M:getTopDataByIndex(index)
	local rank_top = self:getRankDataByDay(self.m_cur_day)
	return rank_top[index]
end

function M:getRankDataByDay(day)
	if self.m_total_rank[day] then
		return self.m_total_rank[day]
	end
	return {}
end

function M:sortRanksTops(rank_data)
	local ranks_top = rank_data
	if rank_data and next(rank_data) then
		table.sort(ranks_top, function(data1, data2)
			return data1.rank < data2.rank
		end)
	end
end

function M:getListData(start_pos, end_pos)
	if start_pos and end_pos then
		local start_pos = math.max(1, start_pos)
		local end_pos = math.min(table.nums(self:getRankDataByDay(self.m_cur_day)), end_pos)
		local rank_data = {}
		for i = start_pos, end_pos do
			rank_data[#rank_data + 1] = self:getRankDataByDay(self.m_cur_day)[i]
		end
		return rank_data
	end
	return self:getRankDataByDay(self.m_cur_day)
end

function M:insertRankData(new_rank_data)
	local rank_top = self:getRankDataByDay(self.m_cur_day)
	if not(next(rank_top)) then
		self:updateTotalRank(new_rank_data)
		rank_top = self:getRankDataByDay(self.m_cur_day)
	else
		for i = 1, #new_rank_data do
			table.insert(rank_top, new_rank_data[i])
		end
	end
end

function M:getAddDes()
	local buff_season_hslj = ConfigManager:getCfgByName("buff_season_hslj") or {}
	local cur_cfg = buff_season_hslj[self.m_version] or {}
	local total_des = ""
	for i = 1, #cur_cfg do
		local des = cur_cfg[i].des
		total_des = total_des .. des
	end
	return total_des
end

function M:getLoadIndex()
	local max_rank_count = 50
	local cur_rank_nums =  table.nums(self:getRankDataByDay(self.m_cur_day))
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

function M:getFreeTimes()
	local high_arena_free_times = ConfigManager:getVipValueByKey("high_arena_free_times", 0)
	local free_times =  self.m_data.free_times or 0
	return high_arena_free_times - free_times
end

-- 定级暂时又不需要了
function M:getRoomId()
	return 1--elf.m_data.room_id or 0
end

function M:getTopData()
	return self:getRankDataByDay(self.m_cur_day) or {}
end

function M:getTopDataByIndex(index)
	local ranks_top = self:getRankDataByDay(self.m_cur_day)
	return ranks_top[index]
end

function M:getRemainingTime()
	local end_time = self.m_data.last_season_time or 0
	return end_time - UserDataManager:getServerTime()
end

function M:getBigRemainingTime()
	local end_time = self.m_data.big_season_etime or 0
	return end_time - UserDataManager:getServerTime()
end

function M:getRankDataByUid( uid )
	local rank_data = nil
	local ranks_top = self:getRankDataByDay(self.m_cur_day) or {}
	for i, v in ipairs(ranks_top) do
		if v.user.uid == uid then
			rank_data = v
		end
	end
	return rank_data
end

function M:getCurTimes()
	local buy_times = self.m_data.daily_times or 0
	return buy_times
end

function M:isMaxTime()
	local max_times = self:getMaxTimes()
	local cur_times = self:getCurTimes()
	local is_max_time = false
	if max_times == 0 then
	elseif cur_times >= max_times then
		is_max_time = true
	end
	return is_max_time
end

function M:getMaxTimes()
	local max_times = ConfigManager:getCommonValueById(448,0)
	return max_times
end

--检查周末双倍
function M:checkWeekendDouble()
	if self.m_data.is_double then
		return self.m_data.is_double == 1
	end
	return false
end

return M
