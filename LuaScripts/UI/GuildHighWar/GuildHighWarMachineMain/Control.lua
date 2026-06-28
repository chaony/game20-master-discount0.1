local M = class("GuildHighWarMachineMainControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_view" then    -- 返回
        self:closeView()
    elseif msg == "machine_btn1" then
        self:openView("GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff1",{data = self.m_model.guild_data})
    elseif msg == "machine_btn2" then
        self:openView("GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff2",{data = self.m_model.user_data_page_2})
    elseif msg == "machine_btn3" then
        self:openView("GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff3",{data = self.m_model.user_data_page_3})
    elseif msg == "refresh_data" then
        self.m_model:InitData(data)
        self.m_view:refreshUI()
    end
end

function M:openPlayer(index)
    local data = self.m_model:GetEndGuildRank()
    if data[index] then
        self:openView("Pops.PlayerInfo", {uid = data[index].user.uid})
    end
end

function M:openOwnPlayer(index)
    local data = self.m_model:GetEndSelfRank()
    if data[index] then
        self:openView("Pops.PlayerInfo", {uid = data[index].user.uid})
    end
end
return M
