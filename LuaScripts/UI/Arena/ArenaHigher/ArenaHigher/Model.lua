---@class ArenaHigherModel:OODataBase
local M = class("ArenaHigherModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("high_arena_arena_index")
end

function M:onEnter()
	self:sortRanksTops()
	self:initSeasonBuffHeros()
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self:sortRanksTops()
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
	return self.m_data.challenges
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

--赛季buff加成英雄
function M:initSeasonBuffHeros()
    local season_notice_tab = ConfigManager:getCfgByName("season_notice")
    local season = UserDataManager:getCurSeason()
    local sea_notice = season_notice_tab[season]
    if sea_notice and next(sea_notice) then
        self.m_season_ids = sea_notice.hero or {}
        self.m_additions = sea_notice.addition or {}
    else
        self.m_season_ids = {}  
        self.m_additions = {}  
    end
end

function M:checkTeams()
	local mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("high_arena_defense"))
	local num = 0
	for k,v in pairs(mult_main_teams) do
		for kk,vv in pairs(v) do
			if vv ~= "" then
				local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(vv)
				local season_buff_num = self:checkSeasonBuffByHero(hero_data.id)
				if season_buff_num > 0 then
					num = season_buff_num + num
				end
			end
		end
	end
	return num
end

function M:checkSeasonBuffByHero(id)
    for k,v in pairs( self.m_season_ids) do
        if id == v then
            if next(self.m_additions) ~= nil then
				return self.m_additions[5]
            else
                return 0
            end
        end
    end
    return 0
end

return M
