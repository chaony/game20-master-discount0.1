local M = class("MultiFormationModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_show_status = self.m_params.show_status or 1
	self.m_sel_formation_index = self.m_params.index or 1
	self.m_main_team = self.m_params.main_team
	self.m_sel_screen = 1
end

function M:getHerosDataByTeam(team)
	local combat = 0
	team = team or {}
	local team_heros_data = {}
	for index = 1,5 do
		local hero_id = team[index] or ""
		local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
		local data = nil
		if hero_data and hero_cfg then
			data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.card_id = hero_id
			data.hero_data = hero_data
			combat = hero_data.combat + combat
		end
		team_heros_data[index] = data or {}
	end
	return team_heros_data, combat
end

--根据id获得英雄数据
function M:getHero(id)
	local hero_cfg = nil
	local hero_data = self.m_assist_heros[id] or self.m_legend_heros[id]
	if hero_data then
		hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	else
		hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
	end

	return hero_data, hero_cfg
end

--检测编队是否与当前战斗类型冲突
function M:checkMultRace(hero_list)
	if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER and self.m_race ~= 0 then
		for i,v in pairs(hero_list) do
			if next(v) ~= nil then
				local data, cfg = self:getHero(v.card_id)
				if self.m_race ~= cfg.race then
					return false
				end
			end
		end
	end
	return true
end

--检测编队是否与当前战斗类型冲突
function M:checkMultRace2(hero_list)
	if hero_list == nil then
		return true
	end
	if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER and self.m_race ~= 0 then
		for i,v in pairs(hero_list) do
			if #v > 0 then
				local data, cfg = self:getHero(v)
				if self.m_race ~= cfg.race then
					return false
				end
			end
		end
	end
	return true
end

return M
