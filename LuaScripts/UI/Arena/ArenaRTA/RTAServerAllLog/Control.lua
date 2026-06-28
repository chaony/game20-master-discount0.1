---@class RTAServerAllLogControl:OOControlBase
---@field m_model RTAServerAllLogModel
---@field m_view RTAServerAllLogView
local M = class("RTAServerAllLogControl",LikeOO.OOControlBase)

function M:onEnter()
    --EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cell_item_node" then
        self:openView("Arena.ArenaRTA.ArenaRTALogDetailPop",{match_id=data.match_id,log_time=data.log_time})
    elseif msg == "refresh_btn" then
        self.m_model:updateData(function()
            self.m_view:refreshUI()
            self.m_view:startRefreshTimer()
        end)
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
