local M = class("PeakArenaMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("arena_outer_index")
end

function M:onEnter()
	--Logger.logError(self.m_data, "----------巅峰--")
end

function M:getPlayerData(index)
	return self.m_data.pre_top_n[tostring(index)] or {}
end

function M:checkHaveTop()
	if self.m_data.pre_top_n == nil or next(self.m_data.pre_top_n) == nil then
		return false
	end 
	return true
end

function M:checkLickData(uid)
	for k,v in pairs(self.m_data.like_data) do
		if uid == v then
			return true
		end
	end
	return false
end

function M:getTopPlayerByIndex(index)
	local c_data = self.m_data.pre_top_n[tostring(index)]
	return c_data.user.uid
end

function M:updateLikeNumByIndex(index, num)
	local c_data = self.m_data.pre_top_n[tostring(index)]
	c_data.like = num or 0
end

--当前赛程 1 小组赛 2 64强赛 3 8强赛  4已结束
function M:getCurBattleStatus()
	if self.m_data.week == 1 then
		return Language:getTextByKey("peak_str_0032")
	elseif self.m_data.week == 2 then
		return Language:getTextByKey("peak_str_0039")
	elseif self.m_data.week == 3 then
		return Language:getTextByKey("peak_str_0040")
	elseif self.m_data.week == 4 then
		return Language:getTextByKey("peak_str_0041")
	elseif self.m_data.week == 5 then
		return Language:getTextByKey("peak_str_0042")
	elseif self.m_data.week == 6 then
		return Language:getTextByKey("peak_str_0034")
	elseif self.m_data.week == 7 then
		return Language:getTextByKey("activities_str_0007")
	else
		return ""	
	end
end

function M:getPreRank()
	if self.m_data.pre_rank == 0 then
		return Language:getTextByKey("new_str_0076")
	end
	return self.m_data.pre_rank
end

function M:getBestRank()
	if self.m_data.best_rank == 0 then
		return Language:getTextByKey("new_str_0076")
	end
	return self.m_data.best_rank
end

function M:getSeasonTime()
	return os.date("%m月%d日%H:%M",self.m_data.season_stime) .." - "..os.date("%m月%d日%H:%M",self.m_data.season_etime)
end

function M:checkTeamLock()
	local c_tim = UserDataManager:getServerTime()
	local end_ts = self:getDownTime()
	local last_tim = end_ts - c_tim
	if last_tim < 3600 then
		return false
	end
	return true
end

function M:getDownTime()
	return UserDataManager.end_ts
end

function M:checkCanClick()
	local lock_tim = ConfigManager:getCommonValueById(415) * 60
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	if server_time >= next_fresh_time+lock_tim then
		return true
	end
	return false
end

-- 0 休赛  1开启
function M:checkOpenType()
	return self.m_data.open_type == 1
end

-- 高阶人数不足128 没有数据
function M:checkHasData()
	if self.m_data.has_data then
		return self.m_data.has_data == 1
	else
		return false	
	end
end

--判断时间 只有1-7之间才可进入
function M:checWeekBl()
	if self.m_data.week and self.m_data.week >= 1 and self.m_data.week <= 7 then
		return true
	else
		return false	
	end
end

function M:getGuessAlert()
	return self.m_data.need_alert or 0
end

--竞猜红点
function M:checkGuessRedPoint()
	local top_arena_guess = UserDataManager:getRedDotByKey("top_arena_guess")
	return top_arena_guess == 1
end

function M:checkTopArenaFinal()
    local top_arena_final = UserDataManager.local_data:getUserDataByKey("top_arena_final", {})
    if top_arena_final and next(top_arena_final) ~= nil then
        if UserDataManager:getServerTime() >= top_arena_final.start_ts then
            return true
        end
    end
    return false
end

return M
