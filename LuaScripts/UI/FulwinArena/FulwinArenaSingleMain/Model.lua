local M = class("FulwinArenaSingleMainModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_ring_id = self.m_params.ring_id
    self:getData("friend_arena_ring_info", {ring_id = self.m_ring_id, need_rank = 1})
end

function M:onEnter()
    --Logger.log(self.m_data,"friend_arena_ring_info ====")
    self.m_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    self.m_battle_record_id = {}
    if self.m_data.battle_log and self.m_data.battle_log.battle_record_id  then
        self:setBattleRecordPlayed(self.m_data.battle_log.battle_record_id)
    end
end

function M:updateData(data)
    if data then
        self.m_old_data = table.copy(self.m_data)
        table.merge(self.m_data, data)
    end
end

-- 是不是房主
function M:isPresident()
    return self.m_uid == self.m_data.ring_info.president
end

-- 取房主信息
function M:getPresidentUser()
    if self.m_data.players then
        for i,v in ipairs(self.m_data.players) do
            if v.user_info.uid == self.m_data.ring_info.president then
                return v
            end
        end
    end
end

-- 取其非房主信息
function M:getPlayerUser()
    if self.m_data.players then
        for i,v in ipairs(self.m_data.players) do
            if v.user_info.uid ~= self.m_data.ring_info.president then
                return v
            end
        end
    end
end

-- 取其非房主旧信息
function M:getOldPlayerUser()
    if self.m_old_data and self.m_old_data.players then
        for i,v in ipairs(self.m_old_data.players) do
            if v.user_info.uid ~= self.m_old_data.ring_info.president then
                return v
            end
        end
    end
end

-- 取其对方信息
function M:getOpponentPlayerUser()
    if self.m_data.players then
        for i,v in ipairs(self.m_data.players) do
            if self.m_uid ~= v.user_info.uid then
                return v
            end
        end
    end
end

-- 是否需要刷新房主
function M:isFreshPresident()
    local persident = self.m_data.ring_info.president
    local old_persident = self.m_old_data and self.m_old_data.ring_info.president
    return persident ~= old_persident
end

-- 是否刷新其他玩家
function M:isFreshPlayer()
    local player = self:getPlayerUser()
    local old_palyer = self:getOldPlayerUser()

    if player and old_palyer then
        return player.user_info.uid ~= old_palyer.user_info.uid
    end
    return true
end

-- 是否刷新准备状态
function M:isFreshReady()
    local player = self:getPlayerUser()
    local old_palyer = self:getOldPlayerUser()
    if player and old_palyer then
        return player.ready ~= old_palyer.ready
    end
    return true
end

-- 记录播放的战斗
function M:setBattleRecordPlayed(id)
    self.m_battle_record_id[id] = true
end

-- 检查是否已经播放过战斗
function M:battleRecordIsPlay(id)
    return self.m_battle_record_id[id]
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