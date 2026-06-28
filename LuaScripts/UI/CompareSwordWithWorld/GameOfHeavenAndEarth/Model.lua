local M = class("GameOfHeavenAndEarthModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("full_service_index")
end

function M:initData(data)
	--定义字段
	self.m_data = data or self.m_data
	self.m_version = self.m_data.version
	self.active_day =  self.m_data.phase_info.active_day		--当前是活动开启的第几天
	self.raceType = -1  --是积分赛还是晋级赛 2 积分赛 ; 3 晋级赛	（前端阶段1-4
	self.guessTimes = self.m_data.guess_times --竞猜次数
	self.total_guess_times = self.m_data.total_guess_times or 0 --总竞猜次数
	self.point_race_guess_data = self.m_data.point_race_guess_data -- 竞猜数据
	self.m_join_self = self.m_data.typ	--自己是否参赛	0未晋级 1天赛 2地赛

	self.phase_day = self.m_data.phase_info.phase_day   --处于阶段的第几天 算作当前的轮数
	self.race_phase = self.m_data.phase_info.phase	--当前阶段 	（全阶段1-8
	self.real_phase = self.m_data.phase_info.real_phase	--当前真实阶段 （区分备战期与战斗期
	self.in_top =  self.m_data.in_top --是否晋级
	self:parseRacePhaseCfg()
	self:getCurRaceType()
	--self:updateCurTm()

	--self.race_point_round = Mathf.Clamp(self.curTm.hour - 9, 1, 10)	--当前处于第几回合
	self:getActivePhaseEndTimeStamp()
end

function M:onEnter()
	--第二阶段战斗期开启6天（phaseDay 每天一回合 共6回合
	--每天打10个轮次（round

	local netData = self.m_data  --获取服务器数据
	self.phase_end_ts = self.m_data.phase_info.phase_end_ts
	self.full_service_phase_cfg = ConfigManager:getCfgByName("full_service_phase")
	self.active_cfg = ConfigManager:getCfgByName("active")
	self:initData()
	
	if self.full_service_phase_cfg then
		self.full_service_phase = self.full_service_phase_cfg[self.m_version]
	end
	self:getActiveTs()
end
--
--function M:getPointRaceNextRoundTimeStamp()
--	local startHour = 10
--	local totalRound = 10
--	local result = -1
--	if self.real_phase ~= 3 and self.curTm.hour < startHour + totalRound - 1 then
--		local roundTS = self:getRoundStartTs(self.race_point_round + 1)
--		local curTimestemp = UserDataManager:getServerTime()
--		result = roundTS - curTimestemp
--		if result <= 0 then
--			self:getNetData("full_service_index", nil, function(data)
--				self:initData(data)
--			end)
--		end
--	end
--	return result 
--end

--获取回合开始时间戳
function M:getRoundStartTs(round)
	round = round and round or 1
	local r = round - 1
	local startHour = 10	--开始时间
	local interval = 1		--每回合的间隔
	local tm = self:getCurTm()
	local round_ts = os.time({year = tm.year, month = tm.month, day = tm.day, hour = startHour + (r * interval) , min = 0, sec = 0})
	return round_ts
end

--获取下个小时的时间戳
function M:getNextHourTs()
	local tm = self:getCurTm()
	local round_ts = os.time({year = tm.year, month = tm.month, day = tm.day, hour = tm.hour + 1 , min = 0, sec = 0})
	return round_ts
end

function M:getActiveByOpenId()
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == 414 and v.version == self.m_version then
			return v
		end
	end
	local active_tab = ConfigManager:getCfgByName("active_season")
	for i, v in pairs(active_tab) do
		if v.open_id == 414 and v.version == self.m_version then
			return v
		end
	end
	return nil
end

--
function M:getActiveTs()
	local active_cfg = self:getActiveByOpenId()
	if active_cfg then
		local start_time = active_cfg.start_time
		local end_time = active_cfg.end_time
		self.start_ts = self:stringTimeByNumberTime(start_time)	--活动开启时间
		self.end_ts = self:stringTimeByNumberTime(end_time)		--活动总结束时间戳

	end
	
	--晋级赛
	if self.race_phase == 5 then --5晋级赛准备阶段
		
	end
end

--获取积分赛结束时间戳
function M:getPointRaceTimeStamp()
	self:getActiveTs()
	local hour_ts = 60 * 60
	local day_ts = hour_ts * 24
	
	local phase4_cfg =  self.full_service_phase[4] 	--积分赛
	local phase4_end_day = phase4_cfg.end_day
	local phase4_start_day = phase4_cfg.start_day
	local phase4_phase_round = phase4_cfg.phase_round
	local phase4_day_start_hour = phase4_phase_round[1]	--积分赛在每日几点开始
	local phase4_day_total_round = phase4_phase_round[2]	--积分赛每日回合数

	local cur_timeStamp = UserDataManager:getServerTime()
	local cur_day_zero_ts = self.start_ts + ((self.active_day - 1) * day_ts)	--当日零点时间戳

	--积分赛
	local pointRace_nextRound_ts = 0
	local pointRace_end_ts = self.start_ts + (phase4_end_day * day_ts)	--积分赛结束时间戳
	local pointRace_start_ts = self.start_ts + ((phase4_start_day - 1) * day_ts) + (phase4_day_start_hour * hour_ts )

	if cur_timeStamp <= pointRace_start_ts then	--准备期 
		pointRace_nextRound_ts = pointRace_start_ts
	else
		local pointRace_last_ts = self.start_ts + (phase4_end_day * day_ts) + ((phase4_day_start_hour + phase4_day_total_round -1 ) * hour_ts )
		local curTm = TimeUtil.gmTime(cur_timeStamp)
		if curTm.hour < phase4_day_start_hour then	--当日比赛还没开始 10
			pointRace_nextRound_ts = cur_day_zero_ts + (phase4_day_start_hour * hour_ts)
		elseif curTm.hour >= phase4_day_start_hour + phase4_day_total_round - 1 then --当日比赛已全部结束 10+10-1
			if self.active_day	== phase4_end_day then --比赛的最后一天
				pointRace_nextRound_ts = -1
			else
				pointRace_nextRound_ts = cur_day_zero_ts + (phase4_day_start_hour * hour_ts) + day_ts
			end
		else
			pointRace_nextRound_ts = cur_day_zero_ts + ((curTm.hour + 1) * hour_ts)
		end
	end
	if pointRace_nextRound_ts < cur_timeStamp then --跨天后刷新
		self:getNetData("full_service_index", nil, function(data)
			self:initData(data)
		end)
	end
	return pointRace_end_ts  , pointRace_nextRound_ts
end

function M:getRiseRaceTimeStamp()
	--晋级赛
	
end


--当前阶段结束的时间戳 
function M:getActivePhaseEndTimeStamp()
	local cur_time_stamp = UserDataManager:getServerTime()
	local phase_end_ts = self.m_data.phase_info.phase_end_ts
	
	local end_time_text = GameUtil:formatTimeBySecond(phase_end_ts - cur_time_stamp,999)
	return phase_end_ts - cur_time_stamp , end_time_text
end

function M:stringTimeByNumberTime(time_string)
	local _, _, y, moth, d, h, mi, s = string.find(time_string, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
	return os.time({year = y, month = moth, day = d, hour = h, min = mi, sec = s})
end


--function M:updateCurTm()
--	local time = UserDataManager:getServerTime()
--	self.curTm = TimeUtil.gmTime(time)
--	return self.curTm
--end

function M:getCurTm()
	local time = UserDataManager:getServerTime()
	local curTm = TimeUtil.gmTime(time)
	return curTm
end

function M:destroy()
	
	M.super.destroy(self)
end

function M:parseRacePhaseCfg()
	local full_service_phase_cfg = ConfigManager:getCfgByName("full_service_phase")
	if next(full_service_phase_cfg) then
		self.m_phase_cfg = full_service_phase_cfg[self.m_version] or {}
		self.m_phase_time_cfg = {}
		self.m_phase_info_cfg = {}
		local phaseNum = 1
		local lastType = 0
		for i,v in ipairs(self.m_phase_cfg) do
			self.m_phase_info_cfg[v.type] = {time = v.phase_time,name = v.name} --Type对应的阶段
			phaseNum = lastType ~= v.type and 1 or phaseNum + 1
			local duration = v.type== 1 and v.end_day or v.end_day - self.m_phase_cfg[i - phaseNum].end_day
			self.m_phase_time_cfg[v.type] = {end_day = v.end_day , duration = duration} --duration 阶段总持续天数
			lastType = v.type
		end
	end
	return self.m_phase_info_cfg , self.m_phase_time_cfg
end

--更新获取当前处于第几阶段 2积分赛，3晋级赛
function M:getCurRaceType()
	self.raceType = 0
	for i, v in ipairs(self.m_phase_time_cfg) do
		if self.active_day > v.end_day then else
			self.raceType = i
			break
		end
	end
	return self.raceType
end

return M