---@class HalfAnniversarySignModel: OODataBase
local M = class("HalfAnniversarySignModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_open_id = self.m_params.open_id or 334
    local tongyong_cfg = ConfigManager:getCfgByName("tongyong_login") or {}
    self.m_login_tab = tongyong_cfg[self.m_open_id] or {}
    self.m_actives = UserDataManager:getActivesDataByOpenId(self.m_open_id)
    self.m_vsn = self.m_actives.version
    self.m_login_data = {}
    self:getData("common_login_index", {open_id = self.m_open_id ,vsn = self.m_vsn})
end

function M:onEnter()
    self:updateNetData(self.m_data)
end

function M:updateNetData(response)
    if response then
        table.merge(self.m_login_data, response.login.receive_days)
        self.m_cur_day = response.cur_day or 0
    end
end

function M:getEndTs()
    if self.m_actives and self.m_actives.end_ts then
        return self.m_actives.end_ts
    end
    return 0
end

function M:getSignRewardByDay(day)
    if self.m_login_tab[self.m_vsn] and self.m_login_tab[self.m_vsn][day] then
        local data = self.m_login_tab[self.m_vsn][day]
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
    for i = 1, #self.m_login_data do
        if tonumber(self.m_login_data[i]) == tonumber(day) then
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
