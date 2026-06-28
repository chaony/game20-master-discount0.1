local M = class("GuildHighWarThreeWorldControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_view" then    -- 返回
        self:closeView()
    elseif msg == "machine_btn1" then
        self:openView("GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff1")
    elseif msg == "machine_btn2" then
        
    elseif msg == "machine_btn3" then
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("guild_high_war_new_0051"), content = Language:getTextByKey("tid#DFBHZBuildBuffdes_1") })
    elseif msg == "recvert_btn" then
        self:openView("GuildHighWar.GuildHighWarMachineMain")
        
    end
end

return M
