local M = class("NewYearDailyShareModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_vsn = self.m_params.version or 1
    self.m_sign_done_data = self.m_params.data or {}
    self.m_spring_festival_login = ConfigManager:getCfgByName("spring_festival_login") or {}
    self.m_actives = self.m_params.actives
    self.m_cur_day = self:getCurDay()
    -- self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    
end

function M:updateNetData(response)
    if response and response.sign_done then
        table.merge(self.m_sign_done_data, response.sign_done)
        self.m_vsn = response.version or self.m_vsn
        self.m_cur_day = self:getCurDay()
    end
end

function M:getEndTs()
    if self.m_actives and self.m_actives.end_ts then
        return self.m_actives.end_ts
    end
    return 0
end

function M:getCurDay()
    local day = 0 
    if self.m_actives then
        local start_ts = self.m_actives.start_ts or 0
        day = GameUtil:NumberOfDaysIntervalDay(start_ts, UserDataManager:getServerTime())
    end
    return day
end

function M:getSignRewardByDay(day)
    if self.m_spring_festival_login[self.m_vsn] and self.m_spring_festival_login[self.m_vsn][day] then
        local data = self.m_spring_festival_login[self.m_vsn][day]
        if data.reward and data.reward[1] then
            return data.reward[1]
        end
    end
    return nil
end

function M:getStatusByDay(day)
    --1可签到， 2已签到， 0不可签到
    local status = 0
    if self:isSignByDay(day) then
        status = 2
    elseif day <= self.m_cur_day then
        status = 1
    end
    return status
end

function M:isSignByDay(day)
    for i = 1, #self.m_sign_done_data do
        if tonumber(self.m_sign_done_data[i]) == tonumber(day) then
            return true
        end
    end
    return false
end

function M:isToday(day)
    return day == self.m_cur_day
end

function M:getActiveCfgByOpenId(open_id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i,v in pairs(active_tab) do
		if v.open_id == open_id then
			return v
		end
	end	
	local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in pairs(active_recharge_tab) do
		if v.open_id == open_id then
			return v
		end
	end	
	return nil
end


return M