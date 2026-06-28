local M = class("GuildHighWarTeamPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("guild_high_war_formation_index")
end

function M:onEnter()
	self.m_open_type = self.m_params.open_type or ""
	self.m_city_id = self.m_params.city_id or 0
	self.m_parent_model = self.m_params.parent_model
	self.mult_main_teams = table.copy(self.m_data.teams)
	self.m_guild_high_war_build = ConfigManager:getCfgByName("guild_high_war_build") or {}
	self.team_num = self.m_data.team_num or 6
end

function M:updateTeams(teams)
	if teams then
		--table.merge(self.mult_main_teams, teams)
		self.mult_main_teams = teams
	end
end

function M:getShowData()
	local show_data = {}
	local high_arena_defense = self.mult_main_teams
	local num = self.team_num
	--for k,v in pairs(high_arena_defense) do 
	--	num = num + 1
	--end
	for i = 1,num do
		local formation_data = high_arena_defense[tostring(i)] or {}
		local team = formation_data.team or {}
		local team_heros_data = {}
		if formation_data.boss_team == false or formation_data.boss_team ==nil then
			for index = 1,5 do
				local hero_id = team[index] or ""
				local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
				local data = nil
				if hero_data and hero_cfg then
					data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
					data.quality = hero_data.evo
					data.card_id = hero_id
					data.hero_data = hero_data
				end
				team_heros_data[index] = data or {}
			end
			show_data[i] = {team_heros_data = team_heros_data,boss_team =false}
		else
			show_data[i] = {team_heros_data = team_heros_data,boss_team =true}
		end
	end
	return show_data
end

function M:getTeamCityId(team_index)
	local formation_data = self.mult_main_teams[tostring(team_index)] or {}
	local city_id = formation_data.city_id or 0
	return city_id
end

function M:getCfgValueByKey(city_id, cfg_key)
	local city_cfg = self.m_guild_high_war_build[city_id] or {}
	if city_cfg[cfg_key] then
		return city_cfg[cfg_key]
	end
	return nil
end

return M
