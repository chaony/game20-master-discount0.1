local M = class("GuildHighWarBattleTeamPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint",nil,"GuildHighWar.GuildHighWarMain")
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "cell" then
        if data ~= self.m_model.m_city_index then
            self.m_model.m_city_index = data
            local city_id = self.m_model:getCityTeamDataByCityId(self.m_model.m_city_index)
            self.m_model:getNetData("guild_high_war_dispatch_teams",{city_id = city_id.city_id},function(response)
                self.m_model:UpdateData(response)
                self.m_view:updateRightLoopScroll()
                self.m_view.m_right_loopscroll_view:moveToCellIndex(1)
            end)
            self.m_view:updateLeftLoopScroll()
        end
    elseif msg == "look_hero" then
        self:openView("GuildHighWar.GuildHighWarDefendTeamPop")
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0010"
        params.content = "tid#TowerActiveDes_02"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "check_tag" then
        self.m_model.m_open_tab_index = data
        if self.m_model.m_open_tab_index == 2 and self.m_model.m_is_open_myteam == false then  --我的队伍
            self.m_model:getNetData("guild_high_war_formation_index",nil,function(response)
                self.m_model.m_is_open_myteam = true
                self.m_model.mult_main_teams = table.copy(response.teams)
                self.m_model.team_num = response.team_num or 6
                self.m_view:refreshUI()
            end)
            return
        end
        self.m_view:refreshUI()
    elseif msg == "formation_edit_btn2" then --前往派遣
        local city_id = self.m_model:getCityTeamDataByCityId(self.m_model.m_city_index)
        EventDispatcher:dipatchEvent("CameraPos", {id = city_id.city_id})
        self:updateMsg("click_city",city_id.city_id,"GuildHighWar.GuildHighWarMain")
        self:closeView()
    elseif msg == "top_button" or  msg == "down_button"  then --上移或者下移
        local index = data.index
        local data = data.cell_data
        local params =
        {
            on_ok_call = function(params)
                local city_data = self.m_model:getCityTeamDataByCityId(self.m_model.m_city_index)
                local allCount = #city_data.team_info
                local num = tonumber(params.text)
                if num == "" or num == nil then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_new_0060"), delay_close = 2})
                    return 
                end
                num = num <1 and 1 or num 
                num = num>allCount and allCount or num
                self.m_model:getNetData("guild_high_war_change_team_sort", {city_id = city_data.city_id,uid = data.uid,tid = data.team_id,rank = num} ,function(response)
                    self.m_model:setTopTeamInfoByCityId(self.m_model.m_city_index,data,num)
                    self.m_view:updateRightLoopScroll()
                    self.m_view.m_right_loopscroll_view:moveToCellIndex(tonumber(params.text))
                end)
            end,
            tips = Language:getTextByKey("guild_high_war_new_0056"),
            title = Language:getTextByKey("guild_high_war_new_0056"),
            placeholder = Language:getTextByKey("guild_high_war_new_0057"),
            text = tostring(index),
            no_close_btn = false,
            is_free = false,
            popType = 1,
        }
        self:openView("Pops.CommonInputPop2", params)
        --local type = msg == "top_button" and 0 or 1
        --self.m_model:setTopTeamInfoByCityId(self.m_model.m_city_index,data,type)
        --self.m_view:updateRightLoopScroll()
    elseif msg == "load_rank" then
        self:requestLoadRank()
        ------------------------------------------------- 我的队伍
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
    
        --------------------------------------------------------------我的队伍
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:changeRankSort(rank_sort)
    local need_request = self.m_model:isHaveRankDataBySort(rank_sort)
    if need_request then
        self:requestNewSortRank(rank_sort)
    else
        self.m_model:setRankSort(rank_sort)
        self.m_view:refreshUI(true)
    end
end

function M:requestNewSortRank(rank_sort)
    local start_pos, end_pos = 1, 10
    local function netCallback(response)
        if self.m_view then
            self.m_model:setRankSort(rank_sort)
            self.m_model:initRankData(response)
            self.m_view:refreshUI(true)
        end
    end
    local params = {}
    params.is_cross = self.m_model.m_params.is_cross
    params.sort = rank_sort
    params.start = start_pos
    params.stop = end_pos
    self.m_model:getNetData("world_rank_info", params, netCallback)
end
function M:requestLoadRank()
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_model:UpdateDataLoad(response)
                self.m_view:updateRightLoopScroll()
            end
        end
        local params = {}
        local city_data = self.m_model:getCityTeamDataByCityId(self.m_model.m_city_index)
        params.city_id = city_data.city_id
        params.start = start_pos
        params.stop = end_pos
        self.m_model:getNetData("guild_high_war_dispatch_teams_page", params, netCallback)
    end
end
-----------------------------我的队伍

function M:requestIndex(team_index)
    local function netCallback(response)
        if self.m_view then
            self.m_model:updateTeams(response.teams)
            self.m_view:UpdateCurrentView()
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
            self.m_view:UpdateCurrentView()
        end
    end
    local params = {}
    params.team_id = team_index
    params.city_id = self.m_model.m_city_id
    local net = flag == true and "guild_high_war_dispatch_boss" or "guild_high_war_dispatch"
    self.m_model:getNetData(net, params, netCallback)
end

function M:requestRecall(team_index,flag)
    local function netCallback(response)
        if self.m_view then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0069"), delay_close = 2})
            self.m_model:updateTeams(response.teams)
            self.m_view:UpdateCurrentView()
        end
    end
    local params = {}
    params.team_id = team_index
    local net = flag == true and "guild_high_war_recall_boss" or "guild_high_war_recall"
    self.m_model:getNetData(net, params, netCallback)
end

-----------------------------我的队伍
return M;
