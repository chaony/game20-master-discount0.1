local M = class("BattleStatisticsModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	local battle_id = self.m_params.battle_id
	if battle_id then
		self:getData("battle_replay", {battle_id = battle_id})
	else
		self:getData()
	end
end

function M:onEnter()
	self.m_log_data = self.m_params.log_data -- 日志信息
	if self.m_params.data then
		self.m_data = self.m_params.data
	end
	table.merge(self.m_data, self.m_log_data or {})
	self.m_round = self.m_params.round or 1
	self.m_mode = self.m_params.mode
	self.m_battle_config_id = self.m_params.battle_config_id
	self.m_boss_id = self.m_params.boss_id or self.m_data.boss_id
	self.m_races = self.m_params.m_races or {}
	self.m_budo_floor = self.m_params.budo_floor
	self:initTopShowData()
	self:initBottomShowData()
end

function M:getUserInfoBySort(sort)
	local battle = self.m_data.battle or {}
	local common = battle.common or {}
	if sort == 1 then -- 左边
		return common.attacker_user or {}
	else --  右边
		local defender_user = common.defender_user or {}
		if _G.next(defender_user) == nil then
			local show_data = self.m_bottom_show_data or {}
			if #show_data > 0 then
				defender_user.avatar = show_data[1].hero_data.id
				defender_user.name = show_data[1].name
				if self.m_mode == GlobalConfig.BATTLE_MODE.MAZE then
					local maze_stage_battle_type = UserDataManager:getTempData("maze_stage_battle_type")
					local maze_cell_type = ConfigManager:getCfgByName("maze_cell_type")
					if maze_stage_battle_type then
						local maze_cell_type_item = maze_cell_type[maze_stage_battle_type] or {}
						defender_user.name = maze_cell_type_item.name or ""
					end
				elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
					local maze_stage_battle_type = UserDataManager:getTempData("gu_jian_maze_battle_type")
					local maze_cell_type = ConfigManager:getCfgByName("maze_cell_type")
					if maze_stage_battle_type then
						local maze_cell_type_item = maze_cell_type[maze_stage_battle_type] or {}
						defender_user.name = maze_cell_type_item.name or ""
					end
				end
			end
		end
		return defender_user
	end
end

function M:getBattleResult()
	local battle = self.m_data.battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	local round_data = rounds[self.m_round] or {}
	local result = round_data.result or 0
	return result
end

function M:initTopShowData()
	local show_data = {}
	local battle = self.m_data.battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	local round_data = rounds[self.m_round] or {}
	local attacker_team = round_data.attacker_team or  {}
	local team = attacker_team.team or {}
	local heros = attacker_team.heros or {}
	show_data = GameUtil:getFormatTeamData(team, heros, false)
	-- 统计数据
	-- ["atk"] = 1364,
	-- ["hp"] = 0,
	-- ["def"] = 0,
	-- ["cure"] = 0,
	local attacker_stats = round_data.attacker_stats or {}
	local max_statistics_data = {}
	for k, v in pairs(show_data) do
		v.statistics_data = attacker_stats[v.card_id] or {}
		v.max_statistics_data = max_statistics_data
		for k1, v1 in pairs(v.statistics_data) do
			if max_statistics_data[k1 .. "_max"] == nil then
				max_statistics_data[k1 .. "_max"] = v1
			else
				max_statistics_data[k1 .. "_max"] = math.max(max_statistics_data[k1 .. "_max"], v1)
			end
		end
	end
	self.m_top_show_data = show_data
end

function M:getTopShowData()
	return self.m_top_show_data or {}
end

function M:initBottomShowData()
	local show_data = {}
	local battle = self.m_data.battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	local round_data = rounds[self.m_round] or {}
	local defender_team = round_data.defender_team or {}
	local team = defender_team.team or {}
	local heros = defender_team.heros or {}
	show_data = GameUtil:getFormatTeamData(team, heros, false)
	-- 统计数据
	local defender_stats = round_data.defender_stats or {}
	local max_statistics_data = {}
	for k, v in pairs(show_data) do
		v.statistics_data = defender_stats[v.card_id] or {}
		v.max_statistics_data = max_statistics_data
		for k1, v1 in pairs(v.statistics_data) do
			if max_statistics_data[k1 .. "_max"] == nil then
				max_statistics_data[k1 .. "_max"] = v1
			else
				max_statistics_data[k1 .. "_max"] = math.max(max_statistics_data[k1 .. "_max"], v1)
			end
		end
	end
	self.m_bottom_show_data = show_data

	if self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
		if self.m_data.battle and self.m_data.battle.common then
			self.m_data.gve_stage_id = self.m_data.battle.common.param
		end
	end
end

function M:getStageName()
	if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		local stage_id
		if self.m_data.battle and self.m_data.battle.common then
			stage_id = self.m_data.battle.common.param
		end
		if stage_id == nil then
			stage_id = UserDataManager:getCurStage()
		end
		local stage = ConfigManager:getCfgByName("stage")
		local stage_cfg = stage[stage_id]
		return Language:getTextByKey("new_str_0124").." "..Language:getTextByKey(stage_cfg.map_point_name)
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
		local stage_id
		if self.m_data.battle and self.m_data.battle.common then
			stage_id = self.m_data.battle.common.param
		end
		if stage_id == nil then
			stage_id = 1
		end
		local stage = ConfigManager:getCfgByName("sword_main")
		local stage_cfg = stage[stage_id] or {}
		return Language:getTextByKey(stage_cfg.name) or ""
	else
		return ""	
	end
end

function M:getBottomShowData()
	return self.m_bottom_show_data or {}
end

return M
