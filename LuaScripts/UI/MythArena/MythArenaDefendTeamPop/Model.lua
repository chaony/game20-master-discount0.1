local M = class("MythArenaDefendTeamPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_back_refresh = self.m_params.back_refresh
	self.m_show_order_btn_flag = self.m_params.show_order_btn_flag
	self.m_edit_status = 1 -- 1 默认状态 2 选择要调整的队伍 3 调整顺序状态
	self.m_battle_array = false
	self:initData(self.m_data)
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("myth_arena_defense"))
	for i = 1,3 do
		if self.mult_main_teams[i] == nil then
			self.mult_main_teams[i] = {}
		end
	end
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

return M
