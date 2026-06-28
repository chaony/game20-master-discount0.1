---@class ArenaNormalModel:OODataBase
local M = class("ArenaNormalModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("arena_arena_index")
end

function M:onEnter()
	self:sortRanksTops()
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self:sortRanksTops()
end

function M:getTopDataByIndex(index)
	return self.m_data.ranks_top[index]
end

function M:getTopData()
	return self.m_data.ranks_top or {}
end

function M:sortRanksTops()
	local ranks_top = self.m_data.ranks_top or {}
	table.sort(ranks_top, function(data1, data2)
		return data1.rank < data2.rank
	end)
	self:initArenaRewardWeekData()
end

function M:getListData()
	return self.m_data.challenges
end

function M:getFreeTimes()
	local arena_free_times = ConfigManager:getVipValueByKey("arena_free_times", 0)
	local free_times =  self.m_data.free_times or 0
	return arena_free_times - free_times
end

-- 定级暂时又不需要了
function M:getRoomId()
	return 1--elf.m_data.room_id or 0
end

-- 检测是否刷新top
function M:checkTopDataRefresh()
	for i,v in ipairs(self.m_data.challenges or {}) do
		for ii, vv in ipairs(self.m_data.ranks_top or {}) do
			if v.user.uid == vv.user.uid and v.rank ~= vv.rank then
				return true
			end
		end
	end
	return false
end


function M:initArenaRewardWeekData()
	local show_data = {}
	local week_win_times = self.m_data.week_win_times or 0
	local week_recv = self.m_data.week_recv or {} -- 周奖励领取记录
	local arena_reward_week = ConfigManager:getCfgByName("arena_reward_week")
	for k,v in pairs(arena_reward_week) do
		local num = v.num or 0
		local status = 0
		if table.keyof(week_recv, k) then
			status = -1-- 已领取
		else
			if week_win_times >= num then
				status = 2 -- 可领取
			else
				status = 0 -- 未完成
			end
		end
		table.insert(show_data, {id = k, cfg = v, status = status})
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.num < data2.cfg.num
	end)
	self.m_arena_reward_week_data = show_data
	self.m_week_win_times = week_win_times
end

function M:getArenaRewardWeekData()
	return self.m_arena_reward_week_data, self.m_week_win_times
end

function M:getRemainingTime()
	local end_time = self.m_data.last_season_time or 0
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
	local max_times = ConfigManager:getCommonValueById(448,0)
	return max_times
end
return M
