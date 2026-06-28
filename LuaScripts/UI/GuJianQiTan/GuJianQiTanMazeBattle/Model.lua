local M = class("GuJianQiTanMazeBattleModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cell_data = self.m_params.data
	self.m_open_flag = self.m_params.open_flag
	self.m_mver = self.m_params.mver;
	self.m_callBack = self.m_params.callBack;
	self.m_cell_id = self.m_params.cell_id;
	self.m_heros_combat = self.m_params.heros_combat
	--当前层
	self.m_cur_floor = self.m_params.cur_floor
	--最大层
	self.m_max_floor = self.m_params.max_floor
	self.m_version = self.m_params.version or 1
	self.m_show_hero_data = self:initShowHeroData()
end

--是否可以快速战斗
function M:canQuickBattle()
	local result = false;
	--if self.m_cur_floor < self.m_max_floor then
	--	--迷宫阵容总战力
	result = self.m_total_combat <  self.m_heros_combat * (ConfigManager:getCommonValueById(289,100)/100);
	--end
	return result

end

function M:getEnemyLevelDelta()
	local sword_akuma_floor_tab = ConfigManager:getCfgByName("sword_akuma_floor") or {}
	local sword_akuma_floor_version_tab = sword_akuma_floor_tab[self.m_version or 1] or {}
	local sword_akuma_item = sword_akuma_floor_version_tab[self.m_cur_floor or 1] or {}
	local enemy_level_delta_key = "little_monster_level"
	if self.m_cell_data.type == 1 then
		enemy_level_delta_key = "little_monster_level"
	elseif self.m_cell_data.type == 2 then
		enemy_level_delta_key = "monster_level"
	elseif self.m_cell_data.type == 3 then
		enemy_level_delta_key = "boss_level"
	end
	local enemy_level_delta = sword_akuma_item[enemy_level_delta_key] or 1
	return enemy_level_delta
end

function M:getCellData()
	local cell_data = table.copy(self.m_cell_data)
	local enemy_level_delta = self:getEnemyLevelDelta()
	local def_team = cell_data.team or {}
	local heros = cell_data.heros or {}
	for k,v in pairs(def_team) do
		local hero_data = heros[v]
		if hero_data then
			hero_data.lv = self:getHeroMaxLevel(math.floor(hero_data.lv * enemy_level_delta))
		end
	end
	return cell_data
end

--初始化显示英雄数据
function M:initShowHeroData()
	self.m_total_combat = 0
	local enemy_level_delta = self:getEnemyLevelDelta()
	local show_data = {}
	local def_team = self.m_cell_data.team or {}
	local heros = self.m_cell_data.heros or {}
	local dyns = self.m_cell_data.dyns or {} -- 战斗开始英雄数据动态信息
	for k,v in pairs(def_team) do
		local hero_data = table.copy(heros[v])
		if hero_data then
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.card_id = v
			data.hero_data = hero_data
			data.dyns = dyns[v] or {}
			data.hero_data.lv = self:getHeroMaxLevel(math.floor(data.hero_data.lv * enemy_level_delta))
			table.insert(show_data, data)
			self.m_total_combat = self.m_total_combat + hero_data.combat
		end
	end
	return show_data
end

function M:getHeroMaxLevel(level)
	if level < 1 then
		level = 1
	end
	local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
	local length = #hero_upgrade
	local level_new = level < length and level or length
	return level_new
end

function M:getShowHeroData()
	return self.m_show_hero_data or {}
end

function M:getShowRewardData()
	local floor_tab = ConfigManager:getCfgByName("sword_akuma_floor") or {}
	local floor_version_tab = floor_tab[self.m_version] or {}
	local floor_item = floor_version_tab[self.m_cur_floor] or {}
	local enemy_type = self.m_cell_data.type or 1
	local box_group_id = floor_item.enemy_drop[enemy_type] or 0
	local box_tab = ConfigManager:getCfgByName("sword_akuma_box") or {}
	local box_item = box_tab[box_group_id] or {}
	--return box_item.box or {}
	for k, v in pairs(box_item) do
		if v.box and next(v.box) then
			return v.box
		end
		break
	end
	return {}
end

return M
