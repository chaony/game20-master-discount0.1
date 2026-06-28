---@class ArenaNormalChallengeModel:OODataBase
local M = class("ArenaNormalChallengeModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("arena_refresh_challenges")
end

function M:onEnter()
	self.m_combat = self.m_params.combat or 0
	self.m_daily_times = self.m_params.daily_times  or 0
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self.m_daily_times = self.m_data.daily_times or 0
end

function M:getListData()
	local data=self.m_data
	return self.m_data.challenges
end

function M:getFreeTimes()
	local arena_free_times = ConfigManager:getVipValueByKey("arena_free_times", 0)
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
