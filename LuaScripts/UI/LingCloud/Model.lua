local M = class("LingCloudModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_high_arena = self.m_params.high_arena
    self.m_top_arena = self.m_params.top_arena
end

function M:initData(data)
    self.m_high_arena = data["high_arena"]
    self.m_top_arena = data["top_arena"]
end

function M:getHightArenaRankName()
	local cfg = ConfigManager:getHighArenaCfgByRank(self.m_high_arena.rank)
    if self.m_high_arena.rank == 0 then
        return Language:getTextByKey("new_str_0076")
    else
        return tostring(cfg.division_name)
    end
end

function M:getTopArenaRank()
    if self.m_top_arena == nil or next(self.m_top_arena) == nil or self.m_top_arena.rank <= 0 then
        return Language:getTextByKey("new_str_0076")
    else
        return self.m_top_arena.rank  
    end
end

function M:getHightArenaRank()
    if self.m_high_arena.rank == 0 then
        return Language:getTextByKey("new_str_0076")
    else
        return self.m_high_arena.rank
    end
end

function M:getHighArenaEndTime()
    local time = self.m_high_arena.last_time - UserDataManager:getServerTime()
	return GameUtil:formatTimeBySecond(time,999)
end

function M:getTopArenaEndTime()
    local time = self.m_top_arena.last_time - UserDataManager:getServerTime()
    return GameUtil:formatTimeBySecond(time,999)
end

function M:checkLastTime()
    local time_1 = self.m_high_arena.last_time - UserDataManager:getServerTime()
    if self.m_top_arena.last_time > 0 then
        local time_2 = self.m_top_arena.last_time - UserDataManager:getServerTime()
        if time_2 <= 0 then 
            return true
        end
    end
    if time_1 <= 0 then
        return true
    end
    return false
end

--
function M:checkCanClick()
	local lock_tim = ConfigManager:getCommonValueById(415) * 60
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	if server_time >= next_fresh_time+lock_tim then
		return true
	end
	return false
end


return M
