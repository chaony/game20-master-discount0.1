local M = class("TowerStageStartBattleModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_race = self.m_params.race or 0
end

function M:getStageRewards()
	local floor_id = UserDataManager:getRaceFloorByRace(self.m_race)
	local cur_tower_stage = ConfigManager:getTowerStageCfgByRaceAndId(self.m_race, floor_id)
	return cur_tower_stage.rewards or {}
end

function M:isMaxStage()
	local floor_id = UserDataManager:getRaceFloorByRace(self.m_race)
	local tower_stage = ConfigManager:getTowerStageCfgByRace(self.m_race)
	return floor_id >= #tower_stage
end

return M
