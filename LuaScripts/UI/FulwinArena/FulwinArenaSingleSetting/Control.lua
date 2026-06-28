local M = class("FulwinArenaSingleSettingControl", LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "set_team_type" then
        self.m_model:setTeamType(data)
    --elseif msg == "set_arraying_time" then
        --self.m_model:setArrayingTime(data)
    elseif msg == "set_pswd_type" then
        self.m_model:setPswdType(data)
        self.m_view:refreshUI()
    elseif msg == "set_fair" then
        self.m_model:setFair(data)
    elseif msg == "ban_btn" then
        self:openBan()
        audio:SendEvtUI("UI_Tab_N5")
    elseif msg == "btn_ok" then
        if self.m_model.m_ring_id then
            self:requestEditRing()
        else
            self:requestCreateRing()
        end
    elseif msg == "btn_titleInfoBtn" then
        self:showHelp()
    end
end

function M:showHelp()
    if self.m_model.m_typ == 1 then
        local content = Language:getTextByKey("Fengyun_challenge_tips_0")
        local titleName = Language:getTextByKey("fylt_str_0020")
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    else
        local content = Language:getTextByKey("Fengyun_challenge_tips_2")
        local titleName = Language:getTextByKey("fylt_str_0021")
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    end
end

function M:openBan()
    local function banBack(ban_race, ban_role_type)
        self.m_model:setBan(ban_race, ban_role_type)
        self.m_view:refreshUI()
    end
    self:openView("FulwinArena.FulwinArenaSettingBan", {callback = banBack, ban_race = self.m_model.m_ban_race, ban_role_type = self.m_model.m_ban_role_type})
end

function M:requestCreateRing()
    local function callfunc(response)
        --Logger.log(response,"requestCreateRing response ======")
        if self.m_view then
            local status = self.m_view:getShareToggleStatus()
            if self.m_model.m_typ == 1 then
                self:openView("FulwinArena.FulwinArenaSingleMain", {ring_id = response.ring_id, invite = status})
            else
                self:openView("FulwinArena.FulwinSecondMain", {ring_id = response.ring_id, invite = status})
            end
            self:updateMsg(99999)
        end
    end
    local params = {}
    params.typ = self.m_model.m_typ
    params.team_type = self.m_model.m_team_type
    params.fair = self.m_model.m_fair
    params.ban_race = self.m_model.m_ban_race
    params.ban_role_type = self.m_model.m_ban_role_type
    if self.m_model.m_pswd_type == 1 then
        params.pswd = self.m_view:getPswd()
    else
        params.pswd = ""
    end
    --Logger.log(params,"requestCreateRing params ======")
    self.m_model:getNetData("friend_arena_create_ring",params, callfunc )
end

function M:requestEditRing()
    local function callfunc(response)
        --Logger.log(response,"requestEditRing response ======")
        if self.m_view then
            if self.m_model.m_typ == 1 then
                self:updateMsg("update_data", nil, "FulwinArena.FulwinArenaSingleMain")
            else
                self:updateMsg("update_data", nil, "FulwinArena.FulwinSecondMain")
            end
            self:closeView()
        end
    end
    local params = {}
    params.ring_id = self.m_model.m_ring_id
    params.team_type = self.m_model.m_team_type
    params.fair = self.m_model.m_fair
    params.ban_race = self.m_model.m_ban_race
    params.ban_role_type = self.m_model.m_ban_role_type
    if self.m_model.m_pswd_type == 1 then
        params.pswd = self.m_view:getPswd()
    else
        params.pswd = ""
    end
    --Logger.log(params,"requestEditRing params ======")
    self.m_model:getNetData("friend_arena_edit_ring",params, callfunc )
end

return M