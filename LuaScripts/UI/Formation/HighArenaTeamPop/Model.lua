---@class HighArenaTeamPopModel:OODataBase
local M = class("HighArenaTeamPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_def_data = self.m_params.def_data --高阶竞技场用的防守数据
	self.m_mode = self.m_params.mode
	self.m_battle_id_tab = self.m_params.battle_id_tab
	self.m_assist_heros = self.m_params.assist_heros

	self.curLayer=self.m_params.layer
	self:getData()
end

function M:onEnter()
	self.m_edit_status = 1 -- 1 默认状态 2 选择要调整的队伍 3 调整顺序状态
	self.m_team_nums = 3
	self.m_def_teams = {}-- 多队推图的防守数据
	self.m_defender_user = nil
	if self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
		local _, _, nums = GameUtil:getBattleStageCfg()
		self.m_team_nums = nums
		self:initEnemyData()
	end

	if self.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
		local _, _, nums = GameUtil:getXiaKeDaoLayerCfg(self.curLayer)
		self.m_team_nums = nums
		self:initEnemyData()
	end
	self:initData()

end

function M:initEnemyData()
	local def_team = {}
	--local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
	for i = 1, self.m_team_nums do
		local battle_id = self.m_battle_id_tab[i]
		local battle_data = ConfigManager:getCfgStageBattle(battle_id)--stage_battle_tab[battle_id]
		if battle_data then
			local monsters = battle_data["monster"]
			for k,v in pairs(monsters) do
				if v.id ~= "null" and v.id ~= nil and v.id > 0 then
					if not(def_team[i]) then
						def_team[i] = {}
					end
					local hero_data = {id = v.id, evo = v.evo, lv = v.lv}
					if not(self.m_defender_user) then
						self.m_defender_user = self:getRightUser(v.id)
					end
					table.insert(def_team[i], hero_data)
				end
			end
		else
			Logger.logError(battle_id, "stage_battle not found id => ")
		end
	end
	self.m_def_teams = def_team
end

function M:getRightUser(hero_id)
	local defender_user = {}
	local hero_cfg = ConfigManager:getCfgByName("hero_detail")[hero_id]
	if hero_cfg then
		defender_user.avatar = hero_cfg.id
		defender_user.name = hero_cfg.name
	end
	return defender_user
end

function M:initData()
	self.m_mult_main_teams = table.copy(self.m_params.mult_main_teams)
	for i = 1,self.m_team_nums do
		if self.m_mult_main_teams[i] == nil then
			self.m_mult_main_teams[i] = {}
		end
	end
	self.m_mult_solts = table.copy(self.m_params.mult_solts)
	for i = 1,self.m_team_nums do
		if self.m_mult_solts[i] == nil then
			self.m_mult_solts[i] = {}
		end
	end
end

function M:getLeftTeamByIndex(index)
	local team = self.m_mult_main_teams[index] or {}
	return team
end

function M:getLeftHeroDataById(hero_id)
	local hero_cfg = nil
	local hero_data = self.m_assist_heros[hero_id]
	if hero_data then
		hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	else
		hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
	end
	local data = nil
	if hero_data and hero_cfg then
		data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
		data.quality = hero_data.evo
		data.card_id = hero_id
		data.hero_data = hero_data
	end
	return data
end

function M:exchangeTeam(index1, index2)
	self.m_mult_main_teams[index1],self.m_mult_main_teams[index2] = self.m_mult_main_teams[index2], self.m_mult_main_teams[index1]
	self.m_mult_solts[index1],self.m_mult_solts[index2] = self.m_mult_solts[index2], self.m_mult_solts[index1]
end
function M:getRightTeamByIndex(index)
	local team = {}
	if self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT
	or self.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
		team = self.m_def_teams[index] or {}
	else
		team = self.m_def_data.teams[index] or {}
	end
	return team
end

function M:getRightHeroDataById(hero_id)
	local heros = self.m_def_data.heros or {}
	local hero_data = heros[hero_id]
	local data = nil
	if hero_data then
		data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
		data.quality = hero_data.evo
		data.card_id = hero_id
		data.hero_data = hero_data
	end
	return data
end

function M:getRightHeroDataByCfg(hero_cfg)
	local hero_cfg = hero_cfg or {}
	local data = {}
	if hero_cfg and next(hero_cfg) then
		data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, 0})
		data.quality = hero_cfg.evo
		data.card_id = hero_cfg.id
	end
	return data
end

return M
