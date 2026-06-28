local M = class("GuildHighWarCityLogPopControl",LikeOO.OOControlBase)

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
    elseif msg == "look_hero" then
        self:openView("GuildHighWar.GuildHighWarDefendTeamPop")
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0010"
        params.content = "tid#TowerActiveDes_02"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "battle_log_btn" then
        self:requestVideo(data.cell_data.battle_log_id)
    elseif msg == "load_rank" then
        self:loadRank()
    end
end

function M:loadRank()
    local cur_num = self.m_model:getRankNums()
    --if cur_num >= 100 or cur_num >= total_num then
    --    return
    --end
    local params = {}
    params.start = cur_num+1
    params.stop = cur_num+10
    params.city_id = self.m_model.m_city_id
    self.m_view:lockTouch()
    local function netCallback(response)
        self.m_view:unlockTouch()
        self.m_model:updateRank(response)
        self.m_load_end = true
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("guild_high_war_city_logs", params, netCallback)
end

function M:requestVideo(id)
    self:openView("Pops.BattleStatistics", {battle_id = id, mode = GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR})
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

return M;
