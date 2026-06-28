local M = class("ArenaFiveRaceModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	--获取种族竞技场接口
	self:getData("race_arena_season_race_arena_index")
end

function M:onEnter()
	self.races = self.m_data.races
	self.m_match_type = 2  -- 0 地级赛 1 天级赛 2 五行联赛
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

function M:getRaceData()
	return self.m_data.races;
end

function M:sortRanksTops()
	--Logger.logError(self.m_data," 进入种族竞技场 ~~~~ ")
	self.users = {}
	local ranks_top = self.m_data.ranks_top or {}
	for i, v in ipairs(ranks_top) do
		self.users[v.user.uid] = v;
	end
	table.sort(ranks_top, function(data1, data2)
		return data1.rank < data2.rank
	end)
	self:initArenaRewardWeekData()
end

function M:getShowFlagTips()
	local tips_id = "tid#TianJiSai_des_1"
	local title_id = "arena_str_0018"
	local title_des_id = "arena_str_0016"
	if self.m_data.show_flag then
		if self.m_data.show_flag == 1 then
			tips_id = "tid#TianJiSai_des_1"
		elseif  self.m_data.show_flag == 2 then
			tips_id = "tid#TianJiSai_des_2"
		elseif  self.m_data.show_flag == 3 then
			tips_id = "tid#TianJiSai_des_7"
			title_id = "arena_str_0024"
			title_des_id = "arena_str_0025"
		elseif  self.m_data.show_flag == 4 then
			tips_id = "tid#LianSai_des_2"
		elseif  self.m_data.show_flag == 5 then
			tips_id = "tid#LianSai_des_7"
			title_id = "arena_str_0024"
			title_des_id = "arena_str_0034"
		end
	end
	return tips_id, title_id, title_des_id
end

function M:getRankDataByUid( uid )
	return self.users[uid];
end


function M:getListData()
	return self.m_data.challenges
end

function M:getFreeTimes()
	local arena_free_times = ConfigManager:getVipValueByKey("race_arena_free_times", 0)
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
	local arena_reward_week = ConfigManager:getCfgByName("season_race_arena_reward_week")
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
	--local end_time = self.m_data.last_season_time or 0
	local end_time = self.m_data.season_etime or 0
	return end_time - UserDataManager:getServerTime()
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

function M:resetShowFlag()
	if self.m_data.show_flag and self.m_data.show_flag > 0 then
		self.m_data.show_flag = 0
	end
end

return M
