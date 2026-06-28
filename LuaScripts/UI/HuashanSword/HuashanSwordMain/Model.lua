local M = class("HuashanSwordMainModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("arena_mountain_hua_arena_index")
end

function M:onEnter()
	self.m_version = self.m_data.version or 1
	self.m_act_data = UserDataManager:getActivesDataByOpenId(276)
	self.m_cur_day = self.m_data.active_day or 1
	self:sortRanksTops()
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self.m_version = self.m_data.version or 1
	self.m_act_data = UserDataManager:getActivesDataByOpenId(276)
	self.m_cur_day = self.m_data.active_day or 1
	self:sortRanksTops()
end

function M:getActStatus()
	self.m_act_data = UserDataManager:getActivesDataByOpenId(276)
	if self.m_act_data and self.m_act_data.open_status then
		return self.m_act_data.open_status
	end
	return 0
end


function M:getEndTs()
	if self.m_act_data and self.m_act_data.end_ts then
		return self.m_act_data.end_ts - UserDataManager:getServerTime()
	end
	return 0
end

function M:getTopDataByIndex(index)
	return self.m_data.ranks_top[index]
end

function M:sortRanksTops()
	local ranks_top = self.m_data.ranks_top or {}
	table.sort(ranks_top, function(data1, data2)
		return data1.rank < data2.rank
	end)
end

function M:getListData()
	return self.m_data.ranks_top
end

function M:insertRankData(new_rank_data)
	for i = 1, #new_rank_data do
		table.insert(self.m_data.ranks_top, new_rank_data[i])
	end
end

function M:getLoadIndex()
	local max_rank_count = 50
	local cur_rank_nums =  table.nums(self.m_data.ranks_top)
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
	local max_times = ConfigManager:getCommonValueById(651,0)
	local free_times =  self.m_data.free_times or 0
	return max_times - free_times
end

-- 定级暂时又不需要了
function M:getRoomId()
	return 1--elf.m_data.room_id or 0
end

function M:getTopData()
	return self.m_data.ranks_top or {}
end

function M:getTopDataByIndex(index)
	return self.m_data.ranks_top[index]
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
	local ranks_top = self.m_data.ranks_top or {}
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
	local max_times = ConfigManager:getCommonValueById(651,0)
	max_times = max_times + ConfigManager:getCommonValueById(652,0)
	return max_times
end

--检查周末双倍
function M:checkWeekendDouble()
	if self.m_data.is_double then
		return self.m_data.is_double == 1
	end
	return false
end

function M:getCurVsnRaces()
	local race_cfg = ConfigManager:getCfgByName("race_arena_raceset_hslj") or {}
	local cur_cfg = race_cfg[self.m_version] or {}
	local races = cur_cfg.race or nil
	return races
end

return M
