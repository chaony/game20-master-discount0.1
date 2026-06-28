---@class TaskModel:OODataBase
local M = class("TaskModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("quest_index")
end

function M:onEnter()
	self.m_open_tab_index = self.m_params.open_tab_index or 1
	self.m_sel_tab_index = nil
	self.m_vm_open_status = UserDataManager:getActivesByOpenId(140) --盗帅是否开启
	--self.m_data.vm_open_status or 0 -- 0未开启   1已开启 战令
	self.m_main_quests_more_id_map = {}
	self:initData()
	if self.m_daily_red_point then
		self.m_open_tab_index = 1
	elseif self.m_weekly_red_point then
		self.m_open_tab_index = 2
	elseif self.m_main_red_point then
		self.m_open_tab_index = 3
	end
end

function M:refreshUI()
	
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self.m_daily_red_point = false
	self.m_weekly_red_point = false
	self.m_main_red_point = false
	self:initDailyQuestsData()
	self:initWeeklyQuestsData()
	self:initMainQuestsData()
	self:initDailyQuestsScoreData()
	self:initWeeklyQuestsScoreData()
end

function M:initDailyQuestsScoreData()
	local show_data = {}
	local daily_point = self.m_data.daily_point or 0
	local daily_score_ids = self.m_data.daily_score_ids or {}
	local daily_score_reward = self.m_data.daily_score_reward or {}
	local quest_score = ConfigManager:getCfgByName("quest_score")
	local cur_stage = UserDataManager:getCurStage()
	for k,v in pairs(quest_score) do
		local stage_id = v.stage_id or 0
		if v.type == 1 and cur_stage >= stage_id then --日常
			local score = v.score or 0
			local status = 0
			if table.keyof(daily_score_ids, k) then
				status = -1-- 已领取
			else
				if daily_point >= score then
					status = 2 -- 可领取
					self.m_have_recv_daily_quests = true
					self.m_daily_red_point = true
				else
					status = 0 -- 未完成
				end
			end
			local rewards = daily_score_reward[tostring(k)] or {}
			if self.m_vm_open_status == true then
				rewards = table.copy(rewards)
				local drop2 = v.drop2 or {}
				table.insertto(rewards, drop2)
			end
			if UserDataManager.m_exchange_vsn > 0 then
				rewards = table.copy(rewards)
				local ex_reward = self:getExchangeQuestRewardByID(k)
				table.insertto(rewards, ex_reward)
			end
			table.insert(show_data, {id = k, cfg = v, status = status, rewards = rewards})
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.score < data2.cfg.score
	end)
	self.m_daily_quests_score_data = show_data
	self.m_daily_point = daily_point
end

function M:getDailyQuestsScoreData()
	return self.m_daily_quests_score_data, self.m_daily_point
end

function M:getExchangeQuestRewardByID(id)
	if UserDataManager.m_exchange_vsn > 0 then
		local exchange_reward_tab = ConfigManager:getCfgByName("exchange_quest_reward")
		if exchange_reward_tab == nil then
			return {}
		end
		local ex_ver_tab = exchange_reward_tab[UserDataManager.m_exchange_vsn]
		local ex_cfg = ex_ver_tab[id]
		if ex_cfg then
			return ex_cfg.reward
		else
			return {}	
		end
	else
		return {}	
	end	
end

function M:initWeeklyQuestsScoreData()
	local show_data = {}
	local weekly_point = self.m_data.weekly_point or 0
	local weekly_score_ids = self.m_data.weekly_score_ids or {}
	local weekly_score_reward = self.m_data.weekly_score_reward or {}
	local quest_score = ConfigManager:getCfgByName("quest_score")
	local cur_stage = UserDataManager:getCurStage()
	for k,v in pairs(quest_score) do
		local stage_id = v.stage_id or 0
		if v.type == 2 and cur_stage >= stage_id then --周常
			local score = v.score or 0
			local status = 0
			if table.keyof(weekly_score_ids, k) then
				status = -1-- 已领取
			else
				if weekly_point >= score then
					status = 2 -- 可领取
					self.m_have_recv_week_quests = true
					self.m_weekly_red_point = true
				else
					status = 0 -- 未完成
				end
			end
			local rewards = weekly_score_reward[tostring(k)] or {}
			if self.m_vm_open_status == true then
				rewards = table.copy(rewards)
				local drop2 = v.drop2 or {}
				table.insertto(rewards, drop2)
			end
			if UserDataManager.m_exchange_vsn > 0 then
				rewards = table.copy(rewards)
				local ex_reward = self:getExchangeQuestRewardByID(k)
				table.insertto(rewards, ex_reward)
			end
			table.insert(show_data, {id = k, cfg = v, status = status, rewards = rewards})
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.score < data2.cfg.score
	end)
	self.m_weekly_quests_score_data = show_data
	self.m_weekly_point = weekly_point
end

function M:getWeeklyQuestsScoreData()
	return self.m_weekly_quests_score_data, self.m_weekly_point
end

function M:initDailyQuestsData()
	local show_data = {}
	local daily_quests = self.m_data.daily_quests or {}
	local quest_time = ConfigManager:getCfgByName("quest_time")
	local reg_day = GameUtil:playerRegisterDays()
	local is_open = BtnOpenUtil:isBtnOpen(80) -- 战令是否开启
	self.m_have_recv_daily_quests = false
	for k,v in pairs(daily_quests) do
		local key = tonumber(k)
		local cfg = quest_time[key]
		if cfg then
			local unlock_days = cfg.unlock_days or 0
			if reg_day >= unlock_days then
				local value = v.value or 0
				local status = v.status or 0 -- 2为领过奖励 - 如果没有领取status没有
				local target_value = cfg.target_value
				if status == 2 then
					status = -1
				else
					if value >= target_value then -- 完成可领取
						status = 2
					end
				end
				local lock_flag, lock_text = self:getQuestLockFlag(cfg.stage_id)
				if lock_flag then
					status = -0.5
				else
					if status == 2 then
						self.m_daily_red_point = true
						self.m_have_recv_daily_quests = true
					end
				end
				local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(cfg, value)
				local rewards = {}
				if cfg.reward1 then
					table.insertto(rewards, cfg.reward1)
				end
				if is_open and cfg.reward2 then
					table.insertto(rewards, cfg.reward2)
				end
				table.insert(show_data, {id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress, lock_flag = lock_flag, lock_text = lock_text, rewards = rewards})
			end
		end
	end
	GameUtil:taskDataSort(show_data)
	self.m_daily_quests_data = show_data
end

function M:getDailyQuestsData()
	return self.m_daily_quests_data
end

function M:getDailyQuestsDataCount()
	return #self.m_daily_quests_data
end

function M:getDailyQuestsDataByIndex(index)
    return self.m_daily_quests_data[index]
end

function M:initWeeklyQuestsData()
	local show_data = {}
	local weekly_quests = self.m_data.weekly_quests or {}
	local quest_time = ConfigManager:getCfgByName("quest_time")
	local is_open = BtnOpenUtil:isBtnOpen(80) -- 战令是否开启
	self.m_have_recv_week_quests = false
	for k,v in pairs(weekly_quests) do
		local key = tonumber(k)
		local cfg = quest_time[key]
		if cfg then
			local value = v.value or 0
			local status = v.status or 0 -- 2为领过奖励 - 如果没有领取status没有
			local target_value = cfg.target_value
			if status == 2 then
				status = -1
			else
				if value >= target_value then -- 完成可领取
					status = 2
				end
			end
			local lock_flag, lock_text = self:getQuestLockFlag(cfg.stage_id)
			if lock_flag then
				status = -0.5
			else
				if status == 2 then
					self.m_weekly_red_point = true
					self.m_have_recv_week_quests = true
				end
			end
			local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(cfg, value)
			local rewards = {}
			if cfg.reward1 then
				table.insertto(rewards, cfg.reward1)
			end
			if is_open and cfg.reward2 then
				table.insertto(rewards, cfg.reward2)
			end
			table.insert(show_data, {id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress, lock_flag = lock_flag, lock_text = lock_text, rewards = rewards})
		end
	end
	GameUtil:taskDataSort(show_data)
	self.m_weekly_quests_data = show_data
end

function M:getWeeklyQuestsData()
	return self.m_weekly_quests_data
end

function M:getWeeklyQuestsDataCount()
	return #self.m_weekly_quests_data
end

function M:geWeeklyQuestsDataByIndex(index)
    return self.m_weekly_quests_data[index]
end

function M:changeMainQuestsMoreStatus(id)
	for k,v in pairs(self.m_main_quests_more_id_map) do
		if id ~= k then
			self.m_main_quests_more_id_map[k] = 1
		end
	end
	self.m_main_quests_more_id_map[id] = self.m_main_quests_more_id_map[id] == 1 and 2 or 1
	self:initMainQuestsData()
end

function M:initMainQuestsData()
	local show_data = {}
	local main_quests = self.m_data.main_quests or {}
	local quest_main = ConfigManager:getCfgByName("quest_main")
	local reg_day = GameUtil:playerRegisterDays()
	local main_ids_map = {}
	local main_show_point_map = {}
	self.m_have_recv_main_quests = false
	for k,v in pairs(main_quests) do
		local key = tonumber(k)
		local cfg = quest_main[key]
		if cfg then
			local unlock_days = cfg.unlock_days or 0
			if reg_day >= unlock_days then
				local value = v.value or 0
				local status = v.status or 0 -- 2为领过奖励 - 如果没有领取status没有
				local target_value = cfg.target_value
				if status == 2 then
					status = -1
				else
					if value >= target_value then -- 完成可领取
						status = 2
					end
				end
				local lock_flag, lock_text = self:getQuestLockFlag(cfg.stage_id)
				if lock_flag then
					status = -0.5
				else
					if status == 2 then
						self.m_main_red_point = true
						self.m_have_recv_main_quests = true
					end
				end
				local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(cfg, value)
				main_ids_map[key] = 1
				local show_point = cfg.show_point or 0
				main_show_point_map[show_point] = key
				table.insert(show_data, {id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress ,lock_flag = lock_flag, lock_text = lock_text, show_more_status = 0, status_sort = status, is_child = false})
			end
		end
	end
	local show_point_tab = {}
	for k,v in pairs(quest_main) do
		local show_point = v.show_point or 0
		local show_key = main_show_point_map[show_point] or 0
		if show_point > 0 and main_ids_map[k] == nil and k > show_key then
			if show_point_tab[show_point] == nil then
				show_point_tab[show_point] = {}
			end
			table.insert(show_point_tab[show_point], {id = k, cfg = v})
		end
	end
	local show_child_data = {}
	for k,v in ipairs(show_data) do
		local show_point = v.cfg.show_point or 0
		local child_data = show_point_tab[show_point] or {}
		if #child_data > 0 then
			local show_more_status = self.m_main_quests_more_id_map[v.id] or 1
			self.m_main_quests_more_id_map[v.id] = show_more_status
			v.show_more_status = show_more_status
			if v.show_more_status == 2 then
				for k1,v1 in ipairs(child_data) do
					local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(v1.cfg, v.cur_progress)
					v1.cur_progress = real_cur_progress
					v1.target_value = real_target_progress
					local lock_flag, lock_text = self:getQuestLockFlag(v1.cfg.stage_id)
					v1.lock_flag = lock_flag
					v1.lock_text = lock_text
					v1.status = real_cur_progress >= real_target_progress and 2 or 0
					v1.status_sort = v.status_sort
					v1.show_more_status = 0
					v1.is_child = true
					table.insert(show_child_data, v1)
				end
			end
		end
	end
	table.insertto(show_data, show_child_data)
	--GameUtil:taskDataSort(show_data)
	self:mainQuestsSort(show_data)
	self.m_main_quests_data = show_data
end

function M:mainQuestsSort(show_data)
	table.sort(show_data, function(data1, data2)
		if data1.status_sort == data2.status_sort then
			if data1.cfg.order == data2.cfg.order then
				if data1.cfg.show_point == data2.cfg.show_point then
					return data1.id < data2.id
				else
					return data1.cfg.show_point < data2.cfg.show_point
				end
			else
				return data1.cfg.order < data2.cfg.order
			end
		else
			return data1.status_sort > data2.status_sort
		end
	end)
end

function M:getMainQuestsData()
	return self.m_main_quests_data
end

function M:getMainQuestsDataCount()
	return #self.m_main_quests_data
end

function M:getMainQuestsDataByIndex(index)
    return self.m_main_quests_data[index]
end

function M:getQuestLockFlag(stage_id)
	return ConfigManager:getQuestLockFlag(stage_id)
end

function M:getDaliyRemainingTime()
	local end_time = self.m_data.daily_etime or 0
	return end_time - UserDataManager:getServerTime()
end

function M:getWeeklyRemainingTime()
	local end_time = self.m_data.weekly_etime or 0
	return end_time - UserDataManager:getServerTime()
end

function M:getRewardUpgradeTipsStr(common_id)
	local reward_upgrade_tab = ConfigManager:getCommonValueById(common_id, {})
	local cur_stage = UserDataManager:getCurStage()
	local stage_cfg = ConfigManager:getCfgByName("stage")
	local tips_str = ""
	for i, v in ipairs(reward_upgrade_tab) do
		if cur_stage < v then
			local stage_cfg_item = stage_cfg[v]
			if stage_cfg_item then
				tips_str = Language:getTextByKey("new_str_0880", Language:getTextByKey(stage_cfg_item.map_point_name))
			end
			break
		end
	end
	return tips_str
end

return M
