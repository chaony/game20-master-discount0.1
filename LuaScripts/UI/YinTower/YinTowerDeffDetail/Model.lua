local M = class("YinTowerDeffDetailModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_index = self.m_params.index
	self.m_vsn = self.m_params.vsn or 1
	self.m_cur_floor = self.m_params.floor or 1
	self.m_cell_data = self.m_params.cell_data
	if self.m_params.cell_data then
		self.m_hero_data = self.m_params.cell_data.hero_data
	end
end

--判断最大层数
function M:isMaxFloor()
	local yinyang_tower = ConfigManager:getCfgByName("yinyang_tower")
	local vsn = self.m_vsn
	local cur_cfg = yinyang_tower[vsn] or {}
	local max_floor = #cur_cfg
	return self.m_cur_floor >= max_floor
end

--初始化显示英雄数据
function M:initShowHeroData()
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

function M:getDesByKey(get_key)
	local vsn = self.m_vsn or 1
	local yinyang_tower_version = ConfigManager:getCfgByName("yinyang_tower_version") or {}
	if yinyang_tower_version and yinyang_tower_version[vsn] and yinyang_tower_version[vsn][get_key] then
		return yinyang_tower_version[vsn][get_key]
	end
	return nil
end

function M:getHeroData()
	return self.m_hero_data or {}
end

function M:getHeroLv()
	if self.m_cell_data and self.m_cell_data.heros then
		for i, v in pairs(self.m_cell_data.heros) do
			return v.lv
		end
	end
	
	return 0
end

function M:getEnemyData()
	return self:initShowHeroData()
end

function M:getGiftData()
	if self.m_cell_data then
		return self.m_cell_data.gifts or {}
	end
	return {}
end

function M:getType()
	if self.m_cell_data then
		return self.m_cell_data.type or {}
	end
	return {}
end

--是否可以碾压
function M:battleOrRolling(position)
	if self.m_cell_data then
		return self.m_cell_data.battle_or_rolling
	end
	return 0
end

--获取遗物奖励
function M:getHeirloom()
	local heirloom = ConfigManager:getCfgByName("heirloom")
	if self.m_cell_data then
		return heirloom[self.m_cell_data.heirloom_id]
	end
	
	return {}
end

--获取英雄信息
function M:getHeroInfo(hero_id)
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	return hero_detail[hero_id]
end

return M
