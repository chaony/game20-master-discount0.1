local M = class("WorldBossMopUpSettlementModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_mode = GlobalConfig.BATTLE_MODE.WORLD_BOSS
	self.m_damage = 0
	self.m_result = 1
	self.m_show_record_btn = false
	self.m_boss_id = self.m_params.boss_id
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data or {}
	self.m_rewards = RewardUtil:mergeRewardAndFormat(self.m_data.reward)
end

function M:getSpinePos(cfg)
	if cfg == nil then
		return Vector3(0,0,0)
	end
	local id = cfg.id
	local hero_tab = ConfigManager:getCfgByName("hero_detail")
	local data_pos = hero_tab[id]["spine_position"]
	local data_scale = hero_tab[id]["hero_scale"] or 1
	return data_pos, data_scale
end

function M:getShowRecordFlag()
	return self.m_mode ~= GlobalConfig.BATTLE_MODE.HIGH_ARENA and self.m_mode ~= GlobalConfig.BATTLE_MODE.WORLD_BOSS
end

-- 获取伤害最高的英雄spine
function M:getHeroBigAnim()
	local spine_anim_name = nil
	--UserDataManager.hero_data:getTeamByKey("stage")
	--local battle = self.m_params.battle_data.battle or {}
	--local rounds = battle.output.rounds or {}
	--local max_atk = 0
	--for k,v in ipairs(rounds) do
	--	local attacker_stats = v.attacker_stats or {}
	--	local attacker_team = v.attacker_team or {}
	--	local dyns = {}
	--	local heros = attacker_team.heros or {}
	--	for k,v in pairs(attacker_stats) do
	--		local atk = v.atk or 0
	--		local hero_data = heros[k] or {}
	--		if atk > max_atk then
	--			max_atk = atk
	--			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id or -1)
	--			if hero_cfg then
	--				spine_anim_name = hero_cfg.hero_spine
	--			end
	--		end
	--	end
	--end
	local m_cfg = nil
	if spine_anim_name == nil then
		local select_hero_combat = 0
		local world_boss_team = UserDataManager.hero_data:getTeamByKey("world_boss")
		for k,v in pairs(world_boss_team) do
			local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
			if data and cfg then
				local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(data, cfg)
				if data.combat and data.combat > select_hero_combat then
					spine_anim_name = hero_skin_cfg.hero_spine
					m_cfg = cfg;
					select_hero_combat =  data.combat
				end
			end
		end
	end
	return spine_anim_name or "hero_0106_SkeletonData",m_cfg
end

function M:checIsSkip()
	return false
end

return M
