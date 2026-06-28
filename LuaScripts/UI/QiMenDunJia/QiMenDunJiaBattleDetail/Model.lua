local M = class("QiMenDunJiaBattleDetailModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("gve_detail", {ver = self.m_params.main_data.ver, cell_id = self.m_params.cell_id})
end

function M:onEnter()
	self.m_main_data = self.m_params.main_data or {}
	self.m_cell_id = self.m_params.cell_id or 0
	self.m_lock_hids = self.m_params.lock_hids or {}
	self.m_lock_one = self.m_params.lock_one or 0
	self.m_version = self.m_params.main_data.ver or 0
	self.m_cell_data = {}
	self.m_reward_data = {}
	self.m_mode = 1	--1，小怪；2，boss
	self.m_star_choose = 3 --选择的难度星级
	self.m_start_confirm_flag = false --是否确定了选择的难度星级
	local localFlagData = UserDataManager.local_data:getUserDataByKey("qimendunjia_chooseFlag",0)
	self.m_star_choose_pass_flag = localFlagData == 1
	self:initCellData()
	self:initRewardData()
	self:initMode()
end

function M:getCellID()
	return self.m_cell_id
end

function M:getCellData()
	return self.m_cell_data
end

function M:initCellData()
	self.m_cell_data = self.m_data.cells[tostring(self.m_cell_id)] or {}
end

function M:initMode()
	local gve_stage = ConfigManager:getCfgByName("gve_stage") or {}
	local cell_data = self.m_cell_data or {}
	local stage_id = cell_data.gve_stage_id or 0
	local gve_stage_item = gve_stage[stage_id] or {}
	if gve_stage_item.stage_type == 4 then
		self.m_mode = 2
	else
		self.m_mode = 1
	end
end

function M:initRewardData()
	local cell_data = self.m_data.cells[tostring(self.m_cell_id)] or {}
	local massif_data = self:getMassifCfg(cell_data.massif_id or 0)
	for k, v in pairs(massif_data.battle_reward_one or {}) do
		table.insert(self.m_reward_data, v)
	end
	for k, v in pairs(massif_data.battle_reward_all or {}) do
		table.insert(self.m_reward_data, v)
	end
end

function M:getMassifCfg(massif_ID)
	massif_ID = massif_ID or 0
	local massif_tab = ConfigManager:getCfgByName("gve_massif")
	local massif_data = massif_tab[massif_ID] or {}
	return massif_data
end

function M:getHeroInfoData()
	local data_tab = {}
	--data_tab.combat_count = self:getTeamCombat()
	if self.m_mode == 2 then --只有boss时，才取技能
		data_tab.boss_skill = self:getBossSkill()
	end
	return data_tab
end

function M:getTeamCombat()
	local combat_count = 0
	local wall_coef = self.m_data.wall_coef or {}
	local hero_data = self.m_cell_data.heros or {}
	combat_count = UserDataManager:calculateGveCombat(hero_data, wall_coef.hp_coef, wall_coef.dps_coef )
	return combat_count
end

function M:getBossSkill()
	local boss_skill_data = {}
	local massif_cfg = self:getMassifCfg(self.m_cell_data.massif_id)
	local boss_id = massif_cfg.boss_is or 0
	local hero_cfg_tab = ConfigManager:getCfgByName("hero_detail")
	local boss_cfg = hero_cfg_tab[boss_id] or {}
	for i = 1, 4 do
		if i < #boss_cfg.skill then
			local skill = GameUtil:getSkill(boss_cfg.skill[i][1][1])
			if skill then
				table.insert(boss_skill_data, skill)
			end
		end
	end
	return boss_skill_data
end

function M:getBossSkillInID()
	local massif_cfg = self:getMassifCfg(self.m_cell_data.massif_id)
	local boss_id = massif_cfg.boss_is or 0
	local hero_cfg_tab = ConfigManager:getCfgByName("hero_detail")
	local boss_cfg = hero_cfg_tab[boss_id] or {}
	return boss_cfg.skill or {}
end

function M:getTeamHeroData()
	local show_data = {}
	local heros = self.m_cell_data.heros or {}
	local def_team = self.m_cell_data.def_team or {}
	if _G.next(def_team) ~= nil then
		for k,v in ipairs(def_team) do
			local hero_data = heros[v]
			if hero_data then
				local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
				data.quality = hero_data.evo
				data.card_id = k
				data.hero_data = hero_data
				data.dyns = {}
				table.insert(show_data, data)
			end
		end
	else
		for k,v in pairs(heros) do
			local hero_data = v
			if hero_data then
				local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
				data.quality = hero_data.evo
				data.card_id = k
				data.hero_data = hero_data
				data.dyns = {}
				table.insert(show_data, data)
			end
		end
	end

	return show_data
end

function M:getCellDefTeam()
	return {heros = self.m_cell_data.heros, def_team = self.m_cell_data.def_team}
end

function M:getRewardData()
	return self.m_reward_data
end

function M:getStrength()
	return self.m_main_data.health
end

function M:getBtnData()
	local btn_data = {}
	btn_data.strength = self:getStrength()
	btn_data.max_damage = 0
	return btn_data
end

function M:getCurrentData()
	local data_temp = {}
	data_temp.top_info_data = self:getTopInfoData()
	data_temp.hero_info_data = self:getHeroInfoData()
	data_temp.enemy_data = self:getTeamHeroData()
	data_temp.reward_data = self:getRewardData()
	data_temp.btn_data = self:getBtnData()
	return data_temp
end

function M:getBattleInfo()
	return self:getMassifCfg(self.m_cell_data.massif_id) or {}
end

function M:getTopInfoData()
	local data_tab = {}
	data_tab.massif_cfg = self:getBattleInfo()
	data_tab.cell_data = self:getCellData()
	return data_tab
end

function M:getJoinGuildDays()
	local start_time = TimeUtil.getIntTimestamp(self.m_main_data.add_guild_ts or 0)
	return math.floor((UserDataManager:getServerTime() - start_time) / (60 * 60 * 24))
end

function M:setChooseStar(star)
	self.m_star_choose = star
end

function M:getChooseStar()
	return self.m_star_choose
end

function M:confirmStart()
	self.m_start_confirm_flag = true
end

function M:isStartConfirmed()
	return self.m_start_confirm_flag
end

function M:updateStarChooseFlag()
	self.m_star_choose_pass_flag = not self.m_star_choose_pass_flag
end

function M:getStarChooseFlag()
	return self.m_star_choose_pass_flag
end

function M:getEnemyLeft()
	local messif_cfg = self:getMassifCfg(self.m_cell_data.massif_id)
	return messif_cfg.massif_hp - self.m_cell_data.cur_num
end

function M:getEnermyHp()
	local messif_cfg = self:getMassifCfg(self.m_cell_data.massif_id) or {}
	local hp_total = messif_cfg.fight_hp or 0
	local hp_cur = hp_total - (self.m_cell_data.cell_damage or 0)
	return hp_total, hp_cur
end

function M:getStarData()
	local star_tab = ConfigManager:getCfgByName("gve_fight_star")
	local messif_cfg = self:getMassifCfg(self.m_cell_data.massif_id) or {}
	local fight_star = messif_cfg.fight_star or 1
	local star_tab_cur = star_tab[fight_star]
	
	local star_data = {}
	if star_tab_cur then
		for i = 1, 3 do
			table.insert(star_data, {star = i, enermy_hp = star_tab_cur.des[i], damage = star_tab_cur.damage[i], explore = star_tab_cur.explore_add[i], lock_flag_custom = i == self.m_star_choose})
		end
	end

	return star_data
end


return M
