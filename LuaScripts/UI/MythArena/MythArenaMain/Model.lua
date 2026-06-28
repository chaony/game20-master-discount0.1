local M = class("MythArenaMainModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("myth_arena_enter")
end

function M:onEnter()
	self.m_version = self.m_data.version or 1
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self.m_version = self.m_data.version or 1
end

function M:getActStatus()
	self.m_act_data = UserDataManager:getActivesDataByOpenId(320)
	if self.m_act_data and self.m_act_data.open_status then
		return self.m_act_data.open_status
	end
	return 0
end

function M:getEndTs()
	if self.m_data and self.m_data.small_end_time then
		return self.m_data.small_end_time - UserDataManager:getServerTime() + 1
	end
	return 0
end

function M:getListData()
	return self.m_data.challenges
end

function M:getFreeTimes()
	local max_times = ConfigManager:getCommonValueById(651,0)
	local free_times =  self.m_data.free_times or 0
	return max_times - free_times
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

function M:getRankRewardByRank(rank)
	rank = rank or -1
	local myth_reward_Exhibition = ConfigManager:getCfgByName("myth_reward_Exhibition") or {}
	for k, v in pairs(myth_reward_Exhibition) do
		if v.type and v.type == 2 then
			return v.reward
		end
	end
	return {}
end
return M
