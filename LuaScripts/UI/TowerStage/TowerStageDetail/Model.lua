local M = class("TowerStageDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
    self.m_transfer = "scale"
    self.m_race = self.m_params.race or 0
    local floor_id = UserDataManager:getRaceFloorByRace(self.m_race)
    local _, is_max = ConfigManager:getTowerStageCfgByRaceAndId(self.m_race, floor_id)
    if not is_max then
        floor_id = floor_id + 1
    end
	self:getData("tower_query_combat_data", {floor_id = floor_id, race = self.m_race})
end

function M:onEnter()
	self.m_players = {}
    local combat_data = self.m_data.combat_data or {}
    local min_server = combat_data.min_server or {}
    local min_friend = combat_data.min_friend or {}
    local min_guild = combat_data.min_guild or {}
    if _G.next(min_server) then
        min_server.relationship = 0
        table.insert(self.m_players, min_server)
    end
    if _G.next(min_friend) then
        min_friend.relationship = 1
        table.insert(self.m_players, min_friend)
    end
    if _G.next(min_guild) then
        min_guild.relationship = 2
        table.insert(self.m_players, min_guild)
    end
end

function M:getPlayerData()
	return self.m_players
end

function M:getPlayerCount()
	return #self.m_players
end

function M:getPlayerDataByIndex(index)
	return self.m_players[index]
end

function M:getStageRewards()
    local tower_floor = UserDataManager:getRaceFloorByRace(self.m_race)
    local cur_tower_stage = ConfigManager:getTowerStageCfgByRaceAndId(self.m_race, tower_floor)
	return cur_tower_stage.rewards or {}
end

return M
