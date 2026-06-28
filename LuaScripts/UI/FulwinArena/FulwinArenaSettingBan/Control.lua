local M = class("FulwinArenaSettingBanControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "btn_ok" then
        self:saveBanData()
    elseif msg == "camp_btn_1" then
        self:setBanRace(1)
    elseif msg == "camp_btn_2" then
        self:setBanRace(2)
    elseif msg == "camp_btn_3" then
        self:setBanRace(3)
    elseif msg == "camp_btn_4" then
        self:setBanRace(4)
    elseif msg == "camp_btn_5" then
        self:setBanRace(5)
    elseif msg == "camp_btn_6" then
        self:setBanRace(6)
    elseif msg == "camp_btn_7" then
        self:setBanRace(7)
    elseif msg == "job_btn_1" then
        self:setBanRoleType(1)
    elseif msg == "job_btn_2" then
        self:setBanRoleType(2)
    elseif msg == "job_btn_3" then
        self:setBanRoleType(3)
    elseif msg == "job_btn_4" then
        self:setBanRoleType(4)
    elseif msg == "job_btn_5" then
        self:setBanRoleType(5)
    elseif msg == "job_btn_6" then
        self:setBanRoleType(6)
    end
end

function M:setBanRace(id)
    if not self.m_model:setBanRace(id) then
        self.m_view:refreshUI()
    end
end

function M:setBanRoleType(id)
    if not self.m_model:setBanRoleType(id) then
        self.m_view:refreshUI()
    end
end

function M:saveBanData()
    if self.m_model.m_callback then
        local ban_race = {}
        for k,v in pairs(self.m_model.m_ban_race) do
            if v == true then
                table.insert(ban_race, k)
            end
        end
        local ban_role_type = {}
        for k,v in pairs(self.m_model.m_ban_role_type) do
            if v == true then
                table.insert(ban_role_type, k)
            end
        end
        table.sort(ban_race, function(a, b) return a<b end)
        table.sort(ban_role_type, function(a, b) return a<b end)
        self.m_model.m_callback(ban_race, ban_role_type)
    end
    self:closeView()
end

return M