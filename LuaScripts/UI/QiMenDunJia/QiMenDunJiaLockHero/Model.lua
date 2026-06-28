local M = class("QiMenDunJiaLockHeroModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.main_data or {}
	self.m_cell_id = self.m_data.cell_id or 0
	self.m_version = self.m_data.ver or 0
	self.m_hero_data = {}
	self.m_reward_data = {}
	self:initHeroData()
	self:initRewardData()
end

function M:initHeroData()
	self.m_hero_data = {}
	local hero_id_data = UserDataManager.hero_data:getTeamByKey("gve") or {}
	local gve_cfg_season = self:getGveBattleConfig()
	local conversion_a = gve_cfg_season.conversion_a or 300 -- 最小等級
	for k,v in ipairs(hero_id_data) do
		local hero_data = table.copy(UserDataManager.hero_data:getHeroDataById(v))
		if hero_data then
			if hero_data.lv < conversion_a then
				hero_data.lv = conversion_a
			end
			if hero_data.clv < conversion_a then
				hero_data.clv = conversion_a
			end
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.card_id = k
			data.hero_data = hero_data
			data.dyns = {}
			data.is_lock_custom = false
			table.insert(self.m_hero_data, data)
		end
	end

	--默认选中第一个
	if self.m_hero_data[1] then
		self.m_hero_data[1].is_lock_custom = true
	end
end

function M:getGveBattleConfig()
    local cur_season = UserDataManager:getCurSeason()
	local gve_cfg = ConfigManager:getCfgByName("gve")
	local gve_cfg_season = gve_cfg[cur_season] or {}
	return gve_cfg_season
end

function M:initRewardData()
	local cell_data = self.m_data.cells[tostring(self.m_data.click_id)] or {}
	local massif_id = cell_data.massif_id
	if massif_id == nil then
		massif_id = self.m_data.custom_massif_id
	end
	local massif_data = self:getMassifCfg(massif_id or 0)
	self.m_reward_data = massif_data.battle_reward_after or {}
end

function M:getMassifCfg(massif_ID)
	massif_ID = massif_ID or 0
	local massif_tab = ConfigManager:getCfgByName("gve_massif")
	local massif_data = massif_tab[massif_ID] or {}
	return massif_data
end

function M:getVersion()
	return self.m_version
end

function M:getHeroData()
	return self.m_hero_data
end

function M:getRewardData()
	return self.m_reward_data
end

function M:updateLockStatus(data)
	self.m_data.lock_one = data.lock_one or 0
	self.m_data.lock_hids = data.lock_hids or {}
end

function M:getLockHeroID()
	for k, v in pairs(self.m_hero_data) do
		if v.is_lock_custom == true then
			return v.hero_data.oid or ""
		end
	end
	return ""
end

return M
