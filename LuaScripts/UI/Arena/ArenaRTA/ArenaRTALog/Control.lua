---@class ArenaRTALogControl:OOControlBase
---@field m_model ArenaRTALogModel
local M = class("ArenaRTALogControl",LikeOO.OOControlBase)

function M:onEnter()
    --EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        --self:updateMsg("refreshRedPoint" ,nil ,"Arena.ArenaRace.ArenaRace")
        self:closeView()
    --elseif msg == "cell_item_node" then
    --	local item_data = data.cell_data
    --    if self.m_model.m_match_type == 1 or(self.m_model.is_zf and self.m_model.team_num==2) then
    --        local item_data = data.cell_data
    --        local status = item_data.status or 0
    --        local rank = status == 0 and item_data.defender_rank or item_data.rank
    --        self:openView("Pops.PlayerInfo", {uid = item_data.user_info.uid, look_model = 6, rank = rank})
    --    elseif  self.m_model.m_match_type == 2 or(self.m_model.is_zf and self.m_model.team_num==3)then
    --        local item_data = data.cell_data
    --        local status = item_data.status or 0
    --        local rank = status == 0 and item_data.defender_rank or item_data.rank
    --        self:openView("Pops.PlayerInfo", {uid = item_data.user_info.uid, look_model = 7, rank = rank})
    --    else
    --        self:openView("Pops.PlayerInfo", {uid = item_data.user_info.uid, look_model = 1})
    --    end
    --elseif msg == "battle_btn" then
    --    local cell_data = data.cell_data
    --    self:arenaSelectDefendTeam(cell_data)
    elseif msg == "detail_btn" then
        --self.m_model:getNetData("rta_battle_log_detail",{match_id=data.match_id},function(data)
        --    self:openView("Arena.ArenaRTA.ArenaRTALogDetailPop",{match_id=data.match_id})
        --end)
        self:openView("Arena.ArenaRTA.ArenaRTALogDetailPop",{match_id=data.match_id,log_time=data.log_time})
    --elseif msg == "master_battle_btn"  then
    --    self:revengeBattleStart(data)
    --elseif msg == "battle_end_refresh_ui" then
    --    self:arenaArenaLogs()
    --elseif msg == "statistics_btn" then
    --    local item_data = data.cell_data
    --    if self.m_model.m_match_type == 1 or self.m_model.m_match_type == 2 then
    --        self:openView("Arena.ArenaHigher.ArenaHigherBattleDetail", {battle_id = item_data.battle_id, log_data = item_data})
    --    else
    --        self:openView("Pops.BattleStatistics", {battle_id = item_data.battle_id, round = 1, log_data = item_data})
    --    end
    end
end

-- 战斗
function M:arenaSelectDefendTeam(data)
    local free_time = self.m_model:getFreeTimes()
    if self.m_model.m_is_zf then
        if free_time > 0 then
            local function netCallback(response)
                local heros_ban=data.heros_ban or {}
                self:openView("Formation",{
                    mode =self.m_model.m_battle_mode,
                    defend_uid = data.user_info.uid,
                    def_data = response,
                    rise_id=self.m_model.rise_id,
                    forbidden_hero_ids=heros_ban,
                    week_rule=self.m_model.m_week_rule,
                    ban_num=self.m_model.ban_num
                })
                self:closeView()
            end
            local params = {rival_uid = data.user_info.uid}
            self.m_model:getNetData("rise_arena_rival_defends", params, netCallback)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("four_tower_str_0008"), delay_close = 2})
        end
    else
        local item_data = UserDataManager.item_data:getItemDataById(1033)
        if free_time > 0 or item_data.num > 0 then
            local function netCallback(response)
                if self.m_model.m_match_type == 1 then
                    local races = GameUtil:getRacesByTopArenaRaceTeamIdx(1, self.m_model.races)
                    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA, def_data = response, defend_uid = data.user_info.uid, formation_index = 1, races = races, top_arena_races = self.m_model.races})
                elseif self.m_model.m_match_type == 2 then
                    local races = self.m_model.races[1]
                    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA, def_data = response, defend_uid = data.user_info.uid, formation_index = 1, races = races, top_arena_races = self.m_model.races})
                else
                    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.RACE_ARENA, defend_uid = data.user_info.uid, races = self.m_model.races, def_data = response})
                end
            end
            local params = {defend_uid = data.user_info.uid}
            if self.m_model.m_match_type == 2 then
                self.m_model:getNetData("race_arena_season_select_defend_team", params, netCallback)
            else
                self.m_model:getNetData("race_arena_select_defend_team", params, netCallback)
            end
        else
            self:openView("Arena.ArenaRace.ArenaRaceTicketBuy")
        end
    end

end

-- 刷新
function M:arenaArenaLogs()
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    if self.m_model.m_match_type == 2 then
        self.m_model:getNetData("race_arena_season_arena_logs", params, netCallback)
    elseif self.m_model.m_params.is_zf then
        self.m_model:getNetData("rise_arena_battle_logs", params, netCallback)
    else
        self.m_model:getNetData("race_arena_arena_logs", params, netCallback)
    end
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" then
        self.m_view:refreshUI()
    end
end

--师傅复仇
function M:revengeBattleStart(data)
    local function netCallback(response)
        self.m_view:refreshUI()
    end
    local params = {battle_id = data.cell_data.battle_id}
    if self.m_model.m_match_type == 2 then
        self.m_model:getNetData("race_arena_season_arena_logs", params, netCallback, nil, nil, GlobalConfig.POST)
    else
        self.m_model:getNetData("race_arena_arena_logs", params, netCallback, nil, nil, GlobalConfig.POST)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M
