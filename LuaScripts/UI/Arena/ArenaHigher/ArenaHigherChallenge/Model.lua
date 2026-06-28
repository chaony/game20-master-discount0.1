local M = class("ArenaHigherChallengeModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("high_arena_refresh_challenges")
end

function M:onEnter()
	self.m_high_arena_skip_formation = UserDataManager.local_data:getUserDataByKey("high_arena_skip_formation", 0)
	self.m_daily_times = self.m_params.daily_times  or 0
end

function M:switchSkipFormation()
	self.m_high_arena_skip_formation = self.m_high_arena_skip_formation == 0 and 1 or 0
	UserDataManager.local_data:setUserDataByKey("high_arena_skip_formation", self.m_high_arena_skip_formation)
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self.m_daily_times = self.m_data.daily_times
end

function M:getListData()
	return self.m_data.challenges
end

function M:getFreeTimes()
	local arena_free_times = ConfigManager:getVipValueByKey("high_arena_free_times", 0)
	local free_times =  self.m_data.free_times or 0
	return arena_free_times - free_times
end

function M:isMaxTime()
	local max_times = self:getMaxTimes()
	local cur_times = self.m_daily_times
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
