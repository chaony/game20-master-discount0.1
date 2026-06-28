local M = class("HuashanSwordDefendTeamModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_back_refresh = self.m_params.back_refresh
	self.m_show_order_btn_flag = self.m_params.show_order_btn_flag
	self.m_edit_status = 1 -- 1 默认状态 2 选择要调整的队伍 3 调整顺序状态
	self.m_battle_array = self.m_params.top_arena or false
	self.m_version = self.m_params.vsn or 1
	self:initData(self.m_data)
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("arena_mountain_hua_defense"))
	self.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey("arena_mountain_hua_defense"))
	for i = 1,3 do
		if self.mult_main_teams[i] == nil then
			self.mult_main_teams[i] = {}
		end
		if self.m_mult_solts[i] == nil then
			self.m_mult_solts[i] = {}
		end
	end
	self:checkTeam()
end

function M:getShowData()
	local show_data = {}
	local high_arena_defense = self.mult_main_teams
	for i = 1,3 do
		local team = high_arena_defense[i] or {}
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
			end
			team_heros_data[index] = data or {}
		end
		show_data[i] = {team_heros_data = team_heros_data}
	end
	return show_data
end

function M:exchangeTeam(index, exchange_index)
	self.mult_main_teams[index], self.mult_main_teams[exchange_index] = self.mult_main_teams[exchange_index], self.mult_main_teams[index]
	self.m_mult_solts[index], self.m_mult_solts[exchange_index] = self.m_mult_solts[exchange_index], self.m_mult_solts[index]
end

function M:getCurVsnRaces()
	local race_cfg = ConfigManager:getCfgByName("race_arena_raceset_hslj") or {}
	local cur_cfg = race_cfg[self.m_version] or {}
	local races = cur_cfg.race or nil
	return races
end

function M:getMultTeamParam()
	local can_set = false
	local teams = {}
	local mult_main_teams = self.mult_main_teams or {}
	for idx = 1, 3 do
		local one_team = mult_main_teams[idx] or {}
		local team = {}
		for i = 1, 5 do
			team[i]= one_team[i] or ""
			if team[i] ~= "" then
				can_set = true
			end
		end
		teams[idx] = team
	end
	return teams, can_set
end

function M:isRightRace(cur_race)
	local race_tab = self:getCurVsnRaces()
	if race_tab then
		for i = 1, #race_tab do
			if cur_race == race_tab[i] then
				return true
			elseif cur_race == 7 and race_tab[i] - 4 < 1 then
				return true
			end
		end
		return false
	end
	return true
end

function M:checkTeam()
	local change_flag = false
	for team_index = 1, #self.mult_main_teams do
		local cur_team = self.mult_main_teams[team_index]
		for i = 1, #cur_team do
			local hero_id = cur_team[i]
			if hero_id ~= "" then
				local _, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
				if self:isRightRace(hero_cfg.race) then
				else
					cur_team[i] = ""
					change_flag = true
				end
			end
		end
	end
	if change_flag then
		UserDataManager.hero_data:updateMultTeams({arena_mountain_hua_defense = self.mult_main_teams})
	end
	return change_flag
end

return M
