local M = class("GuildHighWarDefendTeamPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "item_click" then
        if data and data.uid then
            self:openView("Pops.PlayerInfo", {uid = data.uid})
        end
    elseif msg == "recall_btn" then
        if data then
            self:requestRecall(data)
        end
    elseif msg == "look_hero" then
        self:openView("GuildHighWar.GuildHighWarDefendTeamPop")
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0010"
        params.content = "tid#TowerActiveDes_02"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:requestRecall(team_id)
    local function netCallback(response)
        if self.m_view then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0069"), delay_close = 2})
            self.m_model:removeTeamData(team_id)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.team_id = team_id
    self.m_model:getNetData("guild_high_war_recall", params, netCallback)
end

function M:destroy()
    M.super.destroy(self)
end

return M;
