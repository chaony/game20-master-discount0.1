---@class PassLineupPopModel:OODataBase
local M = class("PassLineupPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_mode = self.m_params.mode
	if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		self:getData("min_combat_data")
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
		self:getData("min_combat_data")
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then 
		local five_pos = self.m_params.five_pos
		self:getData("five_combat_data", {position = five_pos})
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or self.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD 
			or self.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or self.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
		self:getData("five_combat_data")
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.TOWER then 
		self:getData("tower_combat_data")
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
		local _race = self.m_params.race 
		self:getData("tower_combat_data", { race= _race})
	end
end

function M:onEnter()
	self.m_team_nums = 0
	if self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		local _, _, team_nums = GameUtil:getBattleStageCfg()
		self.m_team_nums = team_nums
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
		local _, _, team_nums = GameUtil:getGuJianStageCfg()
		self.m_team_nums = team_nums
	end
	self.m_result = self.m_data.result
end

function M:getShowData()
	return self.m_result
end

return M
