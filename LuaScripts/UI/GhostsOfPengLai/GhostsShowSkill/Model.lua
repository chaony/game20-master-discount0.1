local M = class("GhostsShowSkillModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	--TODO：通过配置修改hero_cid
	self.hero_cid = 703
	self.enemy_cid = 292
	local open_id = 432
	local activityData = UserDataManager:getActivesDataByOpenId(open_id)
	local version = activityData.version or 1
	self.new_card_cfg = ConfigManager:getCfgByName("new_card") or {}
	self.cur_vsn_cfg = self.new_card_cfg[version] or {}
	self.hero_cid = self.cur_vsn_cfg["hero_id"] or self.hero_cid
	self.enemy_cid = self.cur_vsn_cfg["enemy_id"] or self.enemy_cid
	self.cfg_des = self.cur_vsn_cfg["des"] or ""
	self.battle_use_skill = nil--战斗中实际使用的技能
	self.show_plus_skill = nil--主界面plus技能展示用
	self.first_init = true
	self.touch_skill_flag = false
	self:initBateleSkillCfg()
	self:initBattleData()
end

function M:initBateleSkillCfg()
	local skill_tab = {}
	for i = 1, 5 do
		local skill_item = self.cur_vsn_cfg["skill" .. i]
		if skill_item then
			skill_tab[i] = skill_item
		end
	end
	self.battle_use_skill = skill_tab
end

function M:getHeroCfg(hero_cid)
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_cid)
	return hero_cfg
end

function M:getHeroSpineName()
	local hero_cfg = self:getHeroCfg(self.hero_cid)
	local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
	return spine_name
end

function M:getHeroSkill(hero_cid)
	local hero_cfg = self:getHeroCfg(hero_cid)
	local skill = {}
	if self.hero_cid == hero_cid then
		skill = self.battle_use_skill
	else
		skill = hero_cfg.skill 
	end
	local max_lv = ConfigManager:getHeroMaxlv(hero_cid)
	return skill, max_lv
end

function M:getNormalSkill(hero_cid)
	local hero_cfg = self:getHeroCfg(hero_cid)
	local skill = {}
	skill = hero_cfg.skill
	local max_lv = ConfigManager:getHeroMaxlv(hero_cid)
	return skill, max_lv
end

function M:getPlusSkill()
	if self.show_plus_skill then
		return self.show_plus_skill
	end
	local skill = {}
	for i = 1, 2 do
		if self.cur_vsn_cfg["show_skill" .. i] and next(self.cur_vsn_cfg["show_skill" .. i]) then
			skill[i] =  self.cur_vsn_cfg["show_skill" .. i]
		end
	end
	self.show_plus_skill = skill
	return self.show_plus_skill
end

function M:initBattleData()
	local battle_json_data = LuaReload("UI.GhostsOfPengLai.GhostsShowSkill.LocalPreBattleData")
	local battle_data = Json.decode(battle_json_data)
	local client_input = battle_data.battle.client_input
	local round_data = client_input[1]
	if round_data then
		local attacker_team = round_data.attacker_team
		local first_hero_oid = nil
		for key, value in pairs(attacker_team.team) do
			if #value > 0 then
				first_hero_oid = value
				break
			end
		end

		local defender_team = round_data.defender_team
		local enemy_hero_oid = nil
		for key, value in pairs(defender_team.team) do
			if #value > 0 then
				enemy_hero_oid = value
				break
			end
		end
		if first_hero_oid then
			local hero_data = attacker_team.heros[first_hero_oid]
			if hero_data then
				self:changeHeroData(hero_data, self.hero_cid)
			end
			self.battle_data = battle_data
		end
		if enemy_hero_oid then
			local hero_data = defender_team.heros[enemy_hero_oid]
			if hero_data then
				self:changeHeroData(hero_data, self.enemy_cid)
			end
			self.battle_data = battle_data
		end
	end
end

function M:changeHeroData(hero_data, hero_cid)
	if hero_data then
		hero_data.id = hero_cid
		hero_data.lv = 999
		hero_data.attrs.atk = GlobalTools.base10000
		hero_data.attrs.hp = GlobalTools:Mul(GlobalTools.base10000, GlobalTools.base1000)
		hero_data.mystic_data = nil
		hero_data.mystics = nil
		local skill = self:getHeroSkill(hero_cid)
		for index = 1, 5 do
			local skill_item = skill[index]
			if skill_item and #skill_item > 0 then
				hero_data.skill[tostring(index)] = skill_item[#skill_item][1]
			else
				hero_data.skill[tostring(index)] = nil
			end
		end
	end
end

function M:getBattleData()
	return self.battle_data
end

return M
