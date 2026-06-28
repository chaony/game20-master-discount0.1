local M = class("HuashanSwordChallengeModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("arena_mountain_hua_refresh_challenges")
end

function M:onEnter()
	self.m_high_arena_skip_formation = UserDataManager.local_data:getUserDataByKey("huashan_skip_formation", 0)
	self.m_daily_times = self.m_params.daily_times  or 0
	self.m_version = self.m_params.vsn or 0
end

function M:switchSkipFormation()
	self.m_high_arena_skip_formation = self.m_high_arena_skip_formation == 0 and 1 or 0
	UserDataManager.local_data:setUserDataByKey("huashan_skip_formation", self.m_high_arena_skip_formation)
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self.m_daily_times = self.m_data.daily_times
end

function M:getCost()
	local system_cost = ConfigManager:getCfgByName("system_cost")
	local system_cost_item = system_cost[10] or {}
	local cur_cost = system_cost_item.cost or {}
	local item_data = RewardUtil:getProcessRewardData(cur_cost[1])
	--local price = item_data and item_data.data_num or 100
	return item_data
end

function M:getListData()
	return self.m_data.challenges
end

function M:getCurVsnRaces()
	local race_cfg = ConfigManager:getCfgByName("race_arena_raceset_hslj") or {}
	local cur_cfg = race_cfg[self.m_version] or {}
	local races = cur_cfg.race or nil
	return races
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
	local mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("arena_mountain_hua"))

	for i = 1,3 do
		if mult_main_teams[i] == nil then
			mult_main_teams[i] = {}
		end
	end
	local change_flag = false
	for team_index = 1, #mult_main_teams do
		local cur_team = mult_main_teams[team_index]
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
		UserDataManager.hero_data:updateMultTeams({arena_mountain_hua = mult_main_teams})
	end
	return change_flag
end

function M:getFreeTimes()
	local max_times = ConfigManager:getCommonValueById(651,0)
	local free_times =  self.m_data.free_times or 0
	return max_times - free_times
end

function M:isMaxTime()
	local max_times = self:getMaxTimes()
	local cur_times = self.m_daily_times
	local is_max_time = false
	if max_times == 0 then
	elseif cur_times >= max_times then
		is_max_time = true
	end
	return is_max_time
end

function M:getMaxTimes()
	local max_times = ConfigManager:getCommonValueById(651,0) 
	max_times = max_times + ConfigManager:getCommonValueById(652,0) 
	return max_times
end

return M
