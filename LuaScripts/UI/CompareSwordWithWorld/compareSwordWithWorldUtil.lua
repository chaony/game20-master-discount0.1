local M = class( "compareSwordWithWorldUtil" , nil )

local ConfigManager = require("DataCenter.ConfigManager")

function M:ctor(version)
    self.m_version = version
    self.full_service_phase_cfg = ConfigManager:getCfgByName("full_service_phase")
    self.active_cfg = ConfigManager:getCfgByName("active")
    if self.full_service_phase_cfg then
        self.full_service_phase = self.full_service_phase_cfg[self.m_version]
    end
end

function M:getActiveByOpenId(version)
    local active_tab = ConfigManager:getCfgByName("active")
    for i, v in pairs(active_tab) do
        if v.open_id == 414 and v.version == (version or 1) then
            return v
        end
    end
    return nil
end

--
function M:getActiveTs(version)
    local active_cfg = self:getActiveByOpenId(version)
    if active_cfg then
        local start_time = active_cfg.start_time
        local end_time = active_cfg.end_time
        self.start_ts = self:stringTimeByNumberTime(start_time)	--活动开启时间
        self.end_ts = self:stringTimeByNumberTime(end_time)		--活动总结束时间戳

    end
end

function M:stringTimeByNumberTime(time_string)
    local _, _, y, moth, d, h, mi, s = string.find(time_string, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
    return os.time({year = y, month = moth, day = d, hour = h, min = mi, sec = s})
end

--获取积分赛结束时间戳
function M:getPointRaceTimeStamp(version , active_day , time_out_callback)
    self:getActiveTs(version or self.m_version)
    local hour_ts = 60 * 60
    local day_ts = hour_ts * 24

    local phase4_cfg =  self.full_service_phase[4] 	--积分赛
    local phase4_end_day = phase4_cfg.end_day
    local phase4_start_day = phase4_cfg.start_day
    local phase4_phase_round = phase4_cfg.phase_round
    local phase4_day_start_hour = phase4_phase_round[1]	--积分赛在每日几点开始
    local phase4_day_total_round = phase4_phase_round[2]	--积分赛每日回合数

    local cur_timeStamp = UserDataManager:getServerTime()
    local cur_day_zero_ts = self.start_ts + ((active_day - 1) * day_ts)	--当日零点时间戳

    --积分赛
    local pointRace_nextRound_ts = 0    --下一个回合开始的时间戳
    local pointRace_nextRound_end_ts = 0    --下一回合结束的时间戳 
    local pointRace_end_ts = self.start_ts + (phase4_end_day * day_ts)	--积分赛结束时间戳
    local pointRace_start_ts = self.start_ts + ((phase4_start_day - 1) * day_ts) + (phase4_day_start_hour * hour_ts )

    if cur_timeStamp <= pointRace_start_ts then	--准备期 
        pointRace_nextRound_ts = pointRace_start_ts
        pointRace_nextRound_end_ts = pointRace_start_ts + hour_ts
    else
        local pointRace_last_ts = self.start_ts + (phase4_end_day * day_ts) + ((phase4_day_start_hour + phase4_day_total_round -1 ) * hour_ts )
        local curTm = TimeUtil.gmTime(cur_timeStamp)
        if curTm.hour < phase4_day_start_hour then	--当日比赛还没开始 10
            pointRace_nextRound_ts = cur_day_zero_ts + (phase4_day_start_hour * hour_ts)
            pointRace_nextRound_end_ts = cur_day_zero_ts +((phase4_day_start_hour + 1) * hour_ts)
        elseif curTm.hour >= phase4_day_start_hour + phase4_day_total_round - 1 then --当日比赛已全部结束 10+10-1
            if active_day	== phase4_end_day then --比赛的最后一天
                pointRace_nextRound_ts = -1
            else
                pointRace_nextRound_ts = cur_day_zero_ts + (phase4_day_start_hour * hour_ts) + day_ts
            end
        else
            pointRace_nextRound_ts = cur_day_zero_ts + ((curTm.hour + 1) * hour_ts)
        end

        if curTm.hour < phase4_day_start_hour + 1 then
            pointRace_nextRound_end_ts = cur_day_zero_ts +((phase4_day_start_hour + 1) * hour_ts)
        elseif curTm.hour >= phase4_day_start_hour + phase4_day_total_round then
            if active_day == phase4_end_day then --比赛的最后一天
                pointRace_nextRound_end_ts = -1
            else
                pointRace_nextRound_end_ts = cur_day_zero_ts + ((phase4_day_start_hour + 1) * hour_ts) + day_ts
            end
        else
            pointRace_nextRound_end_ts = cur_day_zero_ts + ((curTm.hour + 1) * hour_ts)
        end
    end
    
    if pointRace_nextRound_ts < cur_timeStamp then --超时刷新
        if time_out_callback then
            time_out_callback()
        end
    end
    return pointRace_end_ts  , pointRace_nextRound_ts ,pointRace_nextRound_end_ts
end


--获取晋级赛结束时间戳
function M:getRiseRaceTimeStamp(version , active_day , nextRound_callback , nextRound_end_callback)
    self:getActiveTs(version or self.m_version)
    local hour_ts = 60 * 60
    local day_ts = hour_ts * 24

    local phase6_cfg =  self.full_service_phase[6] 	--晋级赛
    local phase6_end_day = phase6_cfg.end_day   --阶段结束天数
    local phase6_start_day = phase6_cfg.start_day   --阶段开始天数
    local phase6_day_start_hour = 10	--晋级赛在每日几点开始

    local cur_timeStamp = UserDataManager:getServerTime()
    local cur_day_zero_ts = self.start_ts + ((active_day - 1) * day_ts)	--当日零点时间戳
    
    --晋级赛
    self.riseRace_nextRound_ts = self.riseRace_nextRound_ts or 0    --下一个回合开始的时间戳
    self.riseRace_nextRound_end_ts = self.riseRace_nextRound_end_ts or 0    --下一回合结束的时间戳 
    local riseRace_end_ts = self.start_ts + (phase6_end_day * day_ts)	--积分赛结束时间戳
    local riseRace_start_ts = self.start_ts + ((phase6_start_day - 1) * day_ts) + (phase6_day_start_hour * hour_ts )

    if self.riseRace_nextRound_end_ts > 0 and self.riseRace_nextRound_end_ts <= cur_timeStamp then --超时刷新
        if nextRound_end_callback then
            nextRound_end_callback()
        end
    end
    if self.riseRace_nextRound_ts > 0 and self.riseRace_nextRound_ts <= cur_timeStamp then
        if nextRound_callback then
            nextRound_callback()
        end
    end
    
    if cur_timeStamp <= riseRace_start_ts then	--准备期 
        self.riseRace_nextRound_ts = riseRace_start_ts
        self.riseRace_nextRound_end_ts = riseRace_start_ts + hour_ts
    else
        local curTm = TimeUtil.gmTime(cur_timeStamp)
        if curTm.hour < phase6_day_start_hour then	--当日比赛还没开始 10
            self.riseRace_nextRound_ts = cur_day_zero_ts + (phase6_day_start_hour * hour_ts)
            self.riseRace_nextRound_end_ts = cur_day_zero_ts +((phase6_day_start_hour + 1) * hour_ts)
        elseif curTm.hour >= phase6_day_start_hour then --当日比赛已全部结束 10+1
            if active_day == phase6_end_day then --比赛的最后一天
                self.riseRace_nextRound_ts = -1
            else
                self.riseRace_nextRound_ts = cur_day_zero_ts + (phase6_day_start_hour * hour_ts) + day_ts
            end
        else
            self.riseRace_nextRound_ts = cur_day_zero_ts + ((curTm.hour + 1) * hour_ts)
        end

        if curTm.hour < phase6_day_start_hour + 1 then
            self.riseRace_nextRound_end_ts = cur_day_zero_ts +((phase6_day_start_hour + 1) * hour_ts)
        elseif curTm.hour >= phase6_day_start_hour + 1 then
            if active_day == phase6_end_day then --比赛的最后一天
                self.riseRace_nextRound_end_ts = -1
            else
                self.riseRace_nextRound_end_ts = cur_day_zero_ts + ((phase6_day_start_hour + 1) * hour_ts) + day_ts
            end
        else
            self.riseRace_nextRound_end_ts = cur_day_zero_ts + ((curTm.hour + 1) * hour_ts)
        end
    end
    return riseRace_end_ts  , self.riseRace_nextRound_ts ,self.riseRace_nextRound_end_ts
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

return M