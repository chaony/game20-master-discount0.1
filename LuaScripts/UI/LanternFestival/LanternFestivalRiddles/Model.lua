local M = class("LanternFestivalRiddlesModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_lantern_festival_cfg = ConfigManager:getCfgByName("lantern_festival") or {}
	self.m_lantern_login_cfg = ConfigManager:getCfgByName("lantern_login") or {}
	self.m_version = self.m_params.version or 1
	self.m_cur_day = self.m_params.cur_day or 1
	self.m_is_done = self.m_params.is_done or {}
	self.m_status = self.m_params.status or {}
	self.m_help_id = self.m_params.help_id or ""
end

function M:initData(response)
	self.m_version = response.version or self.m_params.version
	self.m_is_done = response.login_recv or self.m_is_done
	self.m_status = response.riddle_ans or self.m_status
end

function M:getDailyRewardByDay(day)
	local reward = {}
	if self.m_lantern_login_cfg[self.m_version] and self.m_lantern_login_cfg[self.m_version][day] then
		reward = self.m_lantern_login_cfg[self.m_version][day]["reward"][1]
	end
	return reward
end

function M:getRiddleRewardByDay(day)
	local reward = {}
	if self.m_lantern_login_cfg[self.m_version] and self.m_lantern_login_cfg[self.m_version][day] then
		reward = self.m_lantern_login_cfg[self.m_version][day]["riddle_reward"]
	end
	return reward
end

function M:isDoneByDay(day)
	for i = 1, #self.m_is_done do
		if tonumber(self.m_is_done[i]) == tonumber(day) then
			return true
		end
	end
	return false
end

--status 0 不可答 1可答 2 答对 3 答错 
function M:getLatternStatusByIndex(index)
	--local status = 0
	local day = tostring(index)
	if self.m_status[day] and self.m_status[day].res ~= 0 then
		return self.m_status[day].res, self.m_status[day]
	elseif self.m_status[day] and self.m_status[day].res == 0 and index <= self.m_cur_day then
		return 1, self.m_status[day]	
	end
	return 0, nil
end

function M:getEndTs()
	local active = UserDataManager:getActivesDataByOpenId(272)
	if active and active.end_ts then
		return active.end_ts - UserDataManager:getServerTime()
	end
	return 0
end

return M
