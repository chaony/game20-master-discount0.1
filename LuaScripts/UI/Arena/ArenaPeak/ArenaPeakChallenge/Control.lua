---@class ArenaPeakChallengeControl:OOControlBase
---@field m_model ArenaPeakChallengeModel
---@field m_view ArenaPeakChallengeView
local M = class("ArenaPeakChallengeControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:updateTime()
    self.m_view:refreshListRemainTime()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_need_refresh_main then
            if self.m_model.m_match_type == 2 then
                self:updateMsg("battle_end_refresh_ui",nil,"Arena.ArenaFiveRace")
            else
                self:updateMsg("battle_end_refresh_ui",nil,"Arena.ArenaRace.ArenaRace")
            end
        end
        self:closeView()
    elseif msg == "attack_btn" then
        if self.m_model:isMaxTime() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("four_tower_str_0008"), delay_close = 2})
            return
        end
        self:arenaSelectDefendTeam(data)
        --local quick_pass = data.quick_pass or 0 --快速通过 1. 可以 0. 不可以
        --if quick_pass == 0 then
        --    self:arenaSelectDefendTeam(data)
        --else
        --    self:arenaQuickPassArena(data)
        --end
    elseif msg == "arena_cell_btn" then
        local look_model = 1
        if self.m_model.rise_id then
            if self.m_model.team_num==2 then
                look_model = 6
            elseif self.m_model.team_num==3 then
                look_model = 7
            end
        else
            if self.m_model.m_match_type == 1 then
                look_model = 6
            elseif self.m_model.m_match_type == 2 then
                look_model = 7
            end
        end
        self:openView("Pops.PlayerInfo", {uid = data.user.uid, look_model = look_model})
    elseif msg == "refresh_btn" then
        self:arenaRefreshChallenges(true)
    elseif msg == "battle_end_refresh_ui" then
        self.m_model.m_need_refresh_main = true
        self:arenaRefreshChallenges()
    elseif msg == "refresh_ui" then
        self:arenaRefreshChallenges()
    elseif msg == "update_data" then
        self.m_model:updateParams(data)
        self.m_view:refreshUI()
    elseif msg == "reward_btn" then
        self:openView("Arena.ArenaRace.ArenaRaceReward", {data = self.m_model.m_data})
    end
end

function M:requestReceive(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data.id
    self.m_model:getNetData("quest_recv_recruit_reward", params, receivetCallback)
end

-- 战斗
function M:arenaSelectDefendTeam(data)
    if data then
        local free_time = self.m_model:getFreeTimes()
        --local item_data = UserDataManager.item_data:getItemDataById(1033)
        if free_time > 0 then
            local function netCallback(response)
                local heros_ban=data.heros_ban or {}

                self:openView("Formation",{
                                            mode =self.m_model.m_battle_mode,
                                           defend_uid = data.user.uid,
                                           def_data = response,
                                            rise_id=self.m_model.rise_id,
                                           forbidden_hero_ids=heros_ban,
                                            week_rule=self.m_model.m_week_rule,
                                            ban_num=self.m_model.m_ban_num
                })
                self:closeView()
            end
            local params = {rival_uid = data.user.uid}
            self.m_model:getNetData("rise_arena_rival_defends", params, netCallback)
        else
            --self:openView("Arena.ArenaRace.ArenaRaceTicketBuy", {match_type = self.m_model.m_match_type})
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("four_tower_str_0008"), delay_close = 2})
        end
    end
end



-- 战斗
function M:arenaQuickPassArena(data)
    if data then
        local mode = GlobalConfig.BATTLE_MODE.RACE_ARENA
        local races = {}
        local free_time = self.m_model:getFreeTimes()
        if self.m_model.m_match_type == 1 then
            races = GameUtil:getRacesByTopArenaRaceTeamIdx(1, self.m_model.races)
            mode = GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA
        elseif self.m_model.m_match_type == 2 then
            races = self.m_model.races[1]
            mode = GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA
        end
        local item_data = UserDataManager.item_data:getItemDataById(1033)
        if free_time > 0 or item_data.num > 0  then
            local function netCallback(response)
                if response.need_battle == 1 then -- 需要战斗
                    if self.m_model.m_match_type == 1 then
                        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA, def_data = response, defend_uid = data.user.uid, formation_index = data.index, races = races, top_arena_races = self.m_model.races})
                    elseif self.m_model.m_match_type == 2 then
                        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA, def_data = response, defend_uid = data.user.uid, formation_index = data.index, races = races, top_arena_races = self.m_model.races})
                    else
                        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.RACE_ARENA, defend_uid = data.user.uid, races = self.m_model.races, def_data = response})
                    end
                else -- 直接胜利
                    self:openView("Settlement", { result = 1, mode = mode, battle_data = response, quick_pass = true, full_mask_flag = true})
                end
            end
            local params = {defend_uid = data.user.uid}
            if self.m_model.m_match_type == 2 then
                self.m_model:getNetData("race_arena_season_quick_pass_race_arena", params, netCallback)
            else
                self.m_model:getNetData("race_arena_quick_pass_race_arena", params, netCallback)

            end
        else
            self:openView("Arena.ArenaRace.ArenaRaceTicketBuy")
        end
    end
end

-- 竞技场刷新敌人
function M:arenaRefreshChallenges(tips)
    local function receivetCallback(response)
        if self.m_view then
            self.m_model:updateData(response)
            --self.m_model:refreshFreeTimes()
            self.m_view:refreshUI()
            if tips then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0236"), delay_close = 2})
            end
        end
    end
    local params = {}
    --if self.m_model.m_match_type == 2 then
    --    self.m_model:getNetData("race_arena_season_refresh_challenges", params, receivetCallback)
    --else
    --    self.m_model:getNetData("race_arena_refresh_challenges", params, receivetCallback)
    --end
    self.m_model:getNetData("rise_arena_refresh_rivals", params, receivetCallback)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" then
        self.m_view:refreshUI()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M;
