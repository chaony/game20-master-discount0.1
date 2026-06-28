---@class ArenaTopDefendTeamModel:OODataBase
local M = class("ArenaTopDefendTeamModel", LikeOO.OODataBase)

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
	self.m_mode = self.m_params.mode or nil
	self.m_races = self.m_params.races or {}
	self.m_team_nums = 2
	if self.m_mode and self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE then
		self.m_team_nums = 3
	end

	if self.m_params.rise_id then
		self.m_team_nums=ConfigManager:getCfgByName("rise_arena_base")[self.m_params.rise_id].team_num
	end

	self:initData(self.m_data)
	--self:getRacesByTeamIdAndWeek()
	self:initSeasonBuffHeros()
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	if self.m_mode ==  GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE then
		self.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("season_race_arena_defense"))
	else
		self.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("top_race_arena_defense"))
	end
	for i = 1, self.m_team_nums do
		if self.mult_main_teams[i] == nil then
			self.mult_main_teams[i] = {}
		end
	end
end

function M:getShowData()
	local show_data = {}
	local high_arena_defense = self.mult_main_teams
	for i = 1, self.m_team_nums do
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

function M:getRacesByTeamIdAndWeek(team_id)
	local top_race_arena_reward_week = ConfigManager:getCfgByName("top_race_arena_reward_week")
	local cur_week_item = top_race_arena_reward_week[top_race_arena_reward_week]
end

function M:exchangeTeam(index, exchange_index)
	self.mult_main_teams[index], self.mult_main_teams[exchange_index] = self.mult_main_teams[exchange_index], self.mult_main_teams[index]
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
    if self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA or --争锋论剑
        self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA or --地赛
        self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA or --天赛
        self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA or --联赛
        self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA or --演武
        self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE or --争锋论剑防守
        self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA_DEFENSE or --地赛防守
        self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE or --天赛防守
        self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE or --联赛防守
        self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE --演武防守
    then
        if sea_notice and next(sea_notice) then
            self.m_season_ids = sea_notice.hero or {}
            self.m_additions = sea_notice.addition or {}
        else
            self.m_season_ids = {}  
            self.m_additions = {}  
        end
    else
        self.m_season_ids = {}  
        self.m_additions = {}   
    end
end

function M:checkSeasonBuffByHero(id)
    for k,v in pairs( self.m_season_ids) do
        if id == v then
            if next(self.m_additions) ~= nil then
                if self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE --争锋论剑
                then
                    return self.m_additions[1]
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA_DEFENSE --地赛
                then
                    return self.m_additions[2]
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE --天赛
                then
                    return self.m_additions[3]
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE --联赛
                then
                    return self.m_additions[4]
                elseif self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA or self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE --演武
                then
                    return self.m_additions[5]
                end
            else
                return 0
            end
        end
    end
    return 0
end

return M
