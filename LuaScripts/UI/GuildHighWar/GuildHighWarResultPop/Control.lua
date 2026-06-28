local M = class("GuildHighWarInvitePopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
        self:updateMsg("refresh_red_point",nil,"GuildHighWar.GuildHighWarMain")
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "item_click" then
        if data and data.uid then
            self:openView("Pops.PlayerInfo", {uid = data.uid})
        end
    elseif msg == "look_hero" then
        self:openView("GuildHighWar.GuildHighWarDefendTeamPop")
    elseif msg == "good" then
        self.m_model:getNetData("guild_high_war_daily_report_like",nil,function(response)
            self.m_model.like_num = response.like
            self.m_model.m_is_good = response.is_liked
            self.m_view:refreshUI()
        end)
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0010"
        params.content = "tid#TowerActiveDes_02"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "statistics_btn" then
        if data and data.cell_data and data.cell_data.battle_log_id then
            self:openView("Pops.BattleStatistics", {battle_id = data.cell_data.battle_log_id})
        end
    elseif msg == "load_rank" then
        self:requestLoadRank()
    elseif msg == "click_btn" then
        if self.m_model:getCurLogsNumsByCityId(data.city_id) == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(self:GetCurrentEmptyText(data.atk_win,data.atk_team_num,data.def_team_num)), delay_close = 2})
            return 
        end --有可能出现没有布阵情况 没有count
        local needToRequest = false
        if self.m_model.m_cur_select_id == data.city_id then
            self.m_model.m_cur_select_id = nil
        else
            self.m_model.m_cur_select_id = data.city_id
            self.m_model.m_click_self = false
            needToRequest = self.m_model:needReuqestNet(self.m_model.m_cur_select_id)
        end
        if needToRequest then
            self:requestNewLogData()
        else
            self.m_view:refreshUI()
        end
        if data and data.index then
            self.m_view.m_loop_scroll_view:moveToCellIndex(data.index)
        end
    elseif msg == "world_btn" then
        self:openView("GuildHighWar.GuildHighWarTotalLogPop")
    elseif msg == "play_btn" then
        self:requestVideo(data.cell_data.battle_log_id)
        -------------------- new 
    elseif msg == "click_city" then
        if self.m_model:getCurLogsNumsByCityId(data.city_id) == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(self:GetCurrentEmptyText(data.atk_win,data.atk_team_num,data.def_team_num)), delay_close = 2})
            return
        end --有可能出现没有布阵情况 没有count
        self:requestNewLogData(true)
    end
end

function M:requestVideo(id)
    self:openView("Pops.BattleStatistics", {battle_id = id, mode = GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR})
end

function M:destroy()
    M.super.destroy(self)
end

function M:requestNewLogData(flag)
    local function netCallback(response)
        if self.m_view then
            self.m_model:updateCityLog(response.logs, self.m_model.m_cur_select_id,flag)
            --self.m_view:refreshUI()
            self.m_view:updateCityTeamScroll()
        end
    end
    local params = {}
    params.start = 1
    params.stop = 10
    params.city_id = self.m_model.m_cur_select_id
    self.m_model:getNetData("guild_high_war_city_logs", params, netCallback)
end

function M:requestLoadRank()
    local start_pos, end_pos = self.m_model:getLoadIndex(self.m_model.m_cur_select_id)
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_logs_load = true
                self.m_model:updateCityLog(response.logs, self.m_model.m_cur_select_id)
                --self.m_view:refreshUI()
                self.m_view:updateCityTeamScroll()
            end
        end
        local params = {}
        params.start = start_pos
        params.stop = end_pos
        params.city_id = self.m_model.m_cur_select_id
        self.m_model:getNetData("guild_high_war_city_logs", params, netCallback)
    end
end

function M:requestGood()
    local function netCallback(response)
        if self.m_view then
            self.m_model:updateGoodData(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("guild_high_war_daily_report_like", nil, netCallback)
end
function M:GetCurrentEmptyText(iswin,atk_num,def_num)
    --1.攻击方胜利：防御方没有派遣队伍，攻击方有队提示“防御方没有派遣队伍攻击方不战而胜”
    --2.防御方获胜：攻击方没有派遣队伍，防御方派遣了队伍或者没派队伍提示“攻击方没有派遣队伍防御方不战而胜”
    --攻击方和防御方的队伍数量后端会传给前端，根据数量去判断一下提示内容
    local text = "guild_high_war_text_0088"
    if iswin == 1 then
        if def_num == 0 then
            text = "guild_high_war_text_00103"
        end
    else
        if atk_num == 0 then
            text = "guild_high_war_text_00104"
        end
    end
    return text
end

return M;
