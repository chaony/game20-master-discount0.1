local M = class("UnionRelicLookModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_relic_data = self.m_params.data
	self.m_look_mode = self.m_params.look_mode or 0
	self.m_assist_heros = self.m_params.assist_heros or {}
end

-- 遗物战斗力加成的英雄
function M:getHeirloomAddHeros()
	local hero_add_ratio_table = {}
	local hero_cid_table = {} --卡牌id
	local hero_rece_table = {} -- 种族id
	local hero_type_table = {} -- 职业类型
	local hero_combat_table = {}
	local team = UserDataManager.hero_data:getTeamByKey("maze") or {}
	local assist_heros = self.m_assist_heros or {} --雇佣的英雄
	for k, v in pairs(team) do
		local hero_data = assist_heros[v]
		local hero_cfg = nil
		if hero_data then
			hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
		else
			hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		end
		if hero_data and hero_cfg then
			local id = hero_data.id
			if hero_cid_table[id] == nil then
				hero_cid_table[id] = {}
			end
			table.insert(hero_cid_table[id], v)

			local race = hero_cfg.race
			if hero_rece_table[race] == nil then
				hero_rece_table[race] = {}
			end
			table.insert(hero_rece_table[race], v)

			local hero_type = hero_cfg.type
			if hero_type_table[hero_type] == nil then
				hero_type_table[hero_type] = {}
			end
			table.insert(hero_type_table[hero_type], v)

			hero_add_ratio_table[v] = 0

			local combat =  UserDataManager:computeHeroCombat(hero_data, hero_cfg)
			hero_combat_table[v] = combat
		end
	end
	
	local data = self.m_relic_data
	local cfg = data.cfg
	if cfg then
		local react = cfg.react or {}
		local atkrating_ratio = cfg.atkrating_ratio or 0
		if #react == 0 then -- 作用全部
			for k,v in pairs(hero_add_ratio_table) do
				hero_add_ratio_table[k] = v + atkrating_ratio
			end
		else
			local react_type = react[1]
			local react_value = react[2]
			if react_type == 1 then-- 1:作用卡牌id
				for k,v in pairs(hero_cid_table[react_value] or {}) do
					hero_add_ratio_table[v] = hero_add_ratio_table[v] + atkrating_ratio
				end
			elseif react_type == 2 then-- 2:作用种族id
				for k,v in pairs(hero_rece_table[react_value] or {}) do
					hero_add_ratio_table[v] = hero_add_ratio_table[v] + atkrating_ratio
				end
			elseif react_type == 3 then-- 3:作用职业类型
				for k,v in pairs(hero_type_table[react_value] or {}) do
					hero_add_ratio_table[v] = hero_add_ratio_table[v] + atkrating_ratio
				end
			end
		end
	end

	
	local show_data = {}
	for k,v in pairs(hero_add_ratio_table) do
		if v > 0 then
			local add_combat = math.floor(hero_combat_table[k]*v/100 + 0.5)
			local hero_data = assist_heros[k] or UserDataManager.hero_data:getHeroDataById(k)
			if hero_data then
				local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
				data.quality = hero_data.evo
				data.card_id = v
				data.clv = hero_data.clv or 0
				data.lv = hero_data.lv or 0
				data.add_combat = add_combat
				table.insert(show_data, data)
			end
		end
	end
	return show_data
end

return M
