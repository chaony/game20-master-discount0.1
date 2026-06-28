local M = class("GuildHighWarTeamPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint",nil,"GuildHighWar.GuildHighWarMain")
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "item_click" then
        if data and data.uid then
            self:openView("Pops.PlayerInfo", {uid = data.uid})
        end
    elseif msg == "formation_edit_btn" then
        if data then
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR, formation_index = data.index,guild_high_war_model = self.m_model.m_parent_model})
        end
    elseif msg == "go_btn" then
        if data and self.m_model.m_open_type ~= "" and self.m_model.m_city_id ~= 0 then
            self:requestDispatch(data.index,data.boss_team)
        end
    elseif msg == "recall_btn" then
        if data then
            self:requestRecall(data.index,data.boss_team)
        end
    elseif msg == "refresh_data" then
        self:requestIndex()
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0010"
        params.content = "tid#TowerActiveDes_02"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:requestIndex(team_index)
    local function netCallback(response)
        if self.m_view then
            self.m_model:updateTeams(response.teams)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.team_id = team_index
    params.city_id = self.m_model.m_city_id
    self.m_model:getNetData("guild_high_war_formation_index", params, netCallback)
end


function M:requestDispatch(team_index,flag)
    local function netCallback(response)
        if self.m_view then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0055"), delay_close = 2})
            self.m_model:updateTeams(response.teams)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.team_id = team_index
    params.city_id = self.m_model.m_city_id
    local net = flag == true and "guild_high_war_dispatch_boss" or "guild_high_war_dispatch"
    self.m_model:getNetData(net, params, netCallback)
end

function M:requestRecall(team_index,flag) -- flag 是否为boss 队伍
    local function netCallback(response)
        if self.m_view then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0069"), delay_close = 2})
            self.m_model:updateTeams(response.teams)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.team_id = team_index
    local net = flag == true and "guild_high_war_recall_boss" or "guild_high_war_recall"
    self.m_model:getNetData(net, params, netCallback)
end

return M;
