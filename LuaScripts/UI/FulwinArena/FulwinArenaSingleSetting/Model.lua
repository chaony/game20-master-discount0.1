local M = class("FulwinArenaSingleSettingModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    self.m_ring_id = self.m_params.ring_id
    self.m_typ = self.m_params.typ or 1 --个人赛
    self.m_team_type = self.m_params.team_type or 1 -- 1-单队， 3-3队
    self.m_fair = self.m_params.fair or 0 -- 公平模式 0-关闭， 1-开启
    self.m_ban_race = self.m_params.ban_race or {} -- 禁用种族
    self.m_ban_role_type = self.m_params.ban_role_type or {} -- 禁用职业
    --self.m_arraying_time = 0 -- 布阵时间
    self.m_pswd_type = 0 -- 进入类型
    self.m_pswd = self.m_params.pswd or ""
    
    self.m_team_type_toggle = {{toggle = "team_one_toggle", value = 1}, {toggle = "team_three_toggle", value = 3}}
    --self.m_arraying_time_toggle = {{toggle = "time_no_toggle", value = 0}, {toggle = "time_one_toggle", value = 60}, {toggle = "time_tow_toggle", value = 120}}
    self.m_pswd_toggle = {{toggle = "auto_join_toggle", value = 0}, {toggle = "password_join_toggle", value = 1}}
end

function M:setTeamType(data)
    self.m_team_type = data
end

--function M:setArrayingTime(data)
--    self.m_arraying_time = data
--end

function M:setPswdType(data)
    self.m_pswd_type = data
end

function M:setFair(data)
    self.m_fair = data and 1 or 0
end

function M:setBan(ban_race, ban_role_type)
    if ban_race then
        self.m_ban_race = ban_race
    end
    if ban_role_type then
        self.m_ban_role_type = ban_role_type
    end
end

return M