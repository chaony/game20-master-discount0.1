

local M = class("FulwinSecondMainModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_ring_id = self.m_params.ring_id
    self:getData("friend_arena_ring_info", {ring_id = self.m_ring_id, need_rank = 0})
end

function M:onEnter()
    Logger.log(self.m_data,"FulwinSecondMainModel data =====")
    self.m_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    self.m_battle_record_id = {}
    if self.m_data.battle_logs then
        local battle_log = self.m_data.battle_logs[1]
        if battle_log then
        --    local server_time = UserDataManager:getServerTime()
        --    local cut_time = server_time - battle_log.log_time
        --    if cut_time > 30 then
                self:setBattleRecordPlayed(battle_log.battle_record_id, self.m_data.ring_info.start_battle_time)
        --    end
        end
    end
end

function M:updateData(data)
    table.merge(self.m_data, data or {})
end

-- 是不是房主
function M:isPresident()
    return self.m_uid == self.m_data.ring_info.president
end

-- 是否被踢
function M:isRemove()
    if self.m_data.players then
        for i,v in ipairs(self.m_data.players) do
            if v.user_info.uid == self.m_uid then
                return false
            end
        end
    end
    return true
end

-- 禁用种族
function M:getDisableRace()
    return self.m_data.ring_info.ban_race
end

function M:getDisableRaceByIndex(index)
    return self.m_data.ring_info.ban_race[index]
end

-- 可用种族
function M:getUsableRace()
    local races = {}
    local disable_race = self:getDisableRace()
    for i,v in ipairs(GlobalConfig.TYPE_HERO_RACE) do
        if not table.keyof(disable_race, i) then
            table.insert(races, i)
        end
    end
    return races
end

-- 禁用职业
function M:getDisableJob()
    return self.m_data.ring_info.ban_role_type
end

function M:getDisableJobByIndex(index)
    return self.m_data.ring_info.ban_role_type[index]
end

function M:getPlayerData(id)
    if self.m_data.players then
        return self.m_data.players[id]
    end
end

-- 是否已都准备
function M:isAllReady()
    if self.m_data.players then
        for i,v in pairs(self.m_data.players) do
            if v.user_info.uid ~= self.m_uid and v.ready ~= 1 then
                return false
            end
        end
        return true
    end
    return false
end

-- 是否已都准备
function M:selfIsReady()
    if self.m_data.players then
        for i,v in pairs(self.m_data.players) do
            if v.user_info.uid == self.m_uid and v.ready == 1 then
                return true
            end
        end
    end
    return false
end

-- 记录播放的战斗
function M:setBattleRecordPlayed(id, time)
    self.m_battle_record_id[id] = time
end

-- 检查是否已经播放过战斗
function M:battleRecordIsPlay(id)
    return self.m_battle_record_id[id]
end

function M:getBattleTime()
    local log_battle_time = nil
    if self.m_data.battle_logs and self.m_data.battle_logs[1] then
        log_battle_time = self.m_battle_record_id[self.m_data.battle_logs[1].battle_record_id]
    end
    return self.m_data.ring_info.start_battle_time, log_battle_time
end

-- 布阵红点
function M:teamFormationRed()
    self.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("friend_arena1"))
    local races = self:getDisableRace()
    local jobs = self:getDisableJob()
    local function checkHero(oid)
        local _, cfg = UserDataManager.hero_data:getHeroDataById(oid)
        if cfg == nil then
            return true
        end
        for i,v in ipairs(races) do
            if v == cfg.race then
                return true
            end
        end

        for i,v in ipairs(jobs) do
            if v == cfg.role_type then
                return true
            end
        end
        return false
    end
    if self.m_data.ring_info.team_type == 1 then
        local team = UserDataManager.hero_data:getTeamByKey("friend_arena1")
        --Logger.log(team, "teamFormationRed team =======")
        if team then
            for k,v in pairs(team) do
                if v and v ~= "" then
                    if checkHero(v) then
                        return true
                    end
                else
                    return true
                end
            end
        else
            return true
        end
    else
        local teams = UserDataManager.hero_data:getMultTeamByKey("friend_arena3")
        --Logger.log(teams, "teamFormationRed teams =======")
        if teams and next(teams) ~= nil then
            for i=1,3 do
                local team = teams[i]
                if team then
                    for k,v in pairs(team) do
                        if v and v ~= "" then
                            if checkHero(v) then
                                return true
                            end
                        else
                            return true
                        end
                    end
                else
                    return true
                end
            end
        else
            return true
        end
    end
    return false
end

return M