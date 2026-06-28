local M = class("FulwinArenaSettingBanModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    self.m_ban_race = {}
    self.m_ban_role_type = {}
    self.m_callback = self.m_params.callback
    if self.m_params.ban_race then
        for i, v in pairs(self.m_params.ban_race) do
            self.m_ban_race[v] = true
        end
    end
    if self.m_params.ban_role_type then
        for i, v in pairs(self.m_params.ban_role_type) do
            self.m_ban_role_type[v] = true
        end
    end
    self.m_race_num = table.nums(self.m_ban_race)
    self.m_job_num = table.nums(self.m_ban_role_type)
end

function M:setBanRace(data)
    if self.m_ban_race[data] then
        self.m_ban_race[data] = false
        self.m_race_num = self.m_race_num - 1
    else
        if self.m_race_num < 4 then
            self.m_ban_race[data] = true
            self.m_race_num = self.m_race_num + 1
        end
    end
end

function M:setBanRoleType(data)
    if self.m_ban_role_type[data] then
        self.m_ban_role_type[data] = false
        self.m_job_num = self.m_job_num - 1
    else
        if self.m_job_num < 4 then
            self.m_ban_role_type[data] = true
            self.m_job_num = self.m_job_num + 1
        end
    end
end

return M