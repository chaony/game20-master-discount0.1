local M = class("GuildHighWarCityPopControl",LikeOO.OOControlBase)

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
    elseif msg == "atk_btn" then
        self:openView("GuildHighWar.GuildHighWarTeamPop", {open_type = "atk", city_id = self.m_model.m_city_id})
    elseif msg == "def_btn" then
        self:openView("GuildHighWar.GuildHighWarTeamPop", {open_type = "def", city_id = self.m_model.m_city_id})
    elseif msg == "log_btn" then
        self:openView("GuildHighWar.GuildHighWarCityLogPop", {city_id = self.m_model.m_city_id})
    elseif msg == "look_btn" then
        self:openView("GuildHighWar.GuildHighWarDefendTeamPop", {city_id = self.m_model.m_city_id,position = self.m_model.m_position})
    elseif msg == "battling_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0083"), delay_close = 2}) --交战提示
        --self:openView("GuildHighWar.GuildHighWarBattlingPop", {city_id = self.m_model.m_city_id})
    elseif msg == "rank_btn" then
        self:openView("GuildHighWar.GuildHighWarRankListPop")
    elseif msg == "tell_atk_btn" then
        self:requestToDeclare()
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

function M:requestToDeclare()
    local function netCallback(response)
        if self.m_view then
            if response then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0054"), delay_close = 2})
                self.m_model:updateCityData(response.citys)
                self:updateMsg("udpate_declare", response.declare_times, "GuildHighWar.GuildHighWarMain")
                self:updateMsg("update_city_data", response.citys, "GuildHighWar.GuildHighWarMain")
                self:closeView()
            end
        end
    end
    local params = {}
    params.city_id = self.m_model.m_city_id
    self.m_model:getNetData("guild_high_war_declare_war", params, netCallback)
end


return M;
