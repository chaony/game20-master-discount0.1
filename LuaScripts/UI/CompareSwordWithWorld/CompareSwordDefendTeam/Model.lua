local M = class("CompareSwordDefendTeamModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_back_refresh = self.m_params.back_refresh 
	self.m_show_order_btn_flag = self.m_params.show_order_btn_flag
	self.m_edit_status = 1 -- 1 默认状态 2 选择要调整的队伍 3 调整顺序状态
	--self.m_battle_array = self.m_params.top_arena or false
	self.m_race_typ = self.m_params.race_typ or 1
	self.m_mode = self.m_params.mode or GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE 
	self.m_teamKey = self.m_params.teamKey
	self.m_team_nums = 3
	if self.m_params.mode == GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION then
		self.m_team_nums = GameUtil:getCompareSwordDefendTeams()
	end
	self:initData(self.m_data)
	self:initSeasonBuffHeros()
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey(self.m_teamKey))	--获取阵容
	self.m_mult_solts = table.copy(UserDataManager:getMultWeaByKey(self.m_teamKey))  
	self.m_normal_arrays = table.copy(UserDataManager:getMultNormalArray(self.m_teamKey))
	self.battle_pet = table.copy(UserDataManager:getMultPets(self.m_teamKey))
	self.m_deployments = {}
	for i = 1,self.m_team_nums do
		table.insert(self.m_deployments,1)			
	end
	--if self.m_battle_array == true then
	--	local top_arena = table.copy(UserDataManager.hero_data:getMultTeamByKey("top_arena"))
	--	local mult_solts = table.copy(UserDataManager:getMultWeaByKey("top_arena"))
	--	if next(top_arena) ~= nil then
	--		self.mult_main_teams = top_arena
	--	end
	--	if next(mult_solts) ~= nil then
	--		self.m_mult_solts = mult_solts
	--	end
	--end
	for i = 1,self.m_team_nums do
		if self.mult_main_teams[i] == nil then
			self.mult_main_teams[i] = {}
		end
		if self.m_mult_solts[i] == nil then
			self.m_mult_solts[i] = {}
		end
	end
	
end

function M:getShowData()
	local show_data = {}
	local high_arena_defense = self.mult_main_teams
	for i = 1,self.m_team_nums do
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

function M:getMultTeamParam()
	local can_set = false
	local teams = {}
	local mult_main_teams = self.mult_main_teams or {}
	for idx = 1, self.m_team_nums do
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


--赛季buff是否开启
function M:checkSeasonBuffOpen()
    return BtnOpenUtil:isBtnOpen(336)
end

function M:initSeasonBuffHeros()
    local season_notice_tab = ConfigManager:getCfgByName("season_notice")
    local season = UserDataManager:getCurSeason()
    local sea_notice = season_notice_tab[season]
    if sea_notice and next(sea_notice) then
        self.m_season_ids = sea_notice.hero or {}
        self.m_additions = sea_notice.addition or {}
    else
        self.m_season_ids = {}  
        self.m_additions = {}  
    end
end


function M:checkSeasonBuffByHero(id)
    for k,v in pairs( self.m_season_ids) do
        if id == v then
            if next(self.m_additions) ~= nil then
				return self.m_additions[5]
            else
                return 0
            end
        end
    end
    return 0
end

return M
