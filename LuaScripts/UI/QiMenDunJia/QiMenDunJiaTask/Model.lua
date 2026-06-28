local M = class("QiMenDunJiaTaskModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("gve_quest_index", {ver = self.m_params.main_data.ver or 0})
end

function M:onEnter()
	self.m_explore_progress_loopScroll_position = 0
	self.m_main_data = self.m_params.main_data or {}
	self.m_version = self.m_main_data.ver or 0
	self.m_explore_value = self.m_main_data.explore_value or 0
	self.m_explore_done_data = self.m_main_data.explore_done or {}
	self.m_explore_data = {}
	self:initExploreData()
	self.m_task_tag_mine = "loopscroll_mine"	--个人
	self.m_task_tag_union = "loopscroll_union"	--帮会
	self.m_select_tab_index = 1
	self.m_mine_task_data = {}
	self.m_union_task_data = {}
	self:initTaskData()
	self.m_red_point_flag_mine = false
	self.m_red_point_flag_union = false
	self.m_red_point_flag_explore = false
	self:updateRedPointStatus()
end

function M:getMainData()
	return self.m_main_data or {}
end

function M:getVersion()
	return self.m_version
end

--任务--
function M:initTaskData()
	self.m_mine_task_data = {}
	self.m_union_task_data = {}

	local cur_season = self.m_version
	local task_data = {}
	table.merge(task_data, self.m_data.quests or {})
	table.merge(task_data, self.m_data.guild_quests or {})
	local task_data_tab = ConfigManager:getCfgByName("gve_task")
	local task_data_season_tab = task_data_tab[cur_season] or {}

	local task_data_sorted = {}
	for k, v in pairs(task_data) do
		table.insert(task_data_sorted, {index = tonumber(k), data = v})
	end
	table.sort(task_data_sorted, function(item1, item2)
		return item1.index < item2.index
	end)

	for k,v in pairs(task_data_sorted) do
		local key = v.index
		local cfg = task_data_season_tab[key]
		if cfg then
			local value = v.data.value or 0
			local status = v.data.status or 0
			if status == 2 then --已完成，便于排序
				status = -2
			end
			local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(cfg, value)
			local task_item = {id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress, lock_flag = false}
			if cfg.task_type == 1 then
				table.insert(self.m_mine_task_data, task_item)
			elseif cfg.task_type == 2 then

				if v.data.status ~= 2 then
					local keep_off_flag = false
					local task_pre_data
					local task_pre_cfg = cfg
					while(task_pre_cfg) do
						for k1, v1 in pairs(self.m_union_task_data) do
							if v1.id == task_pre_cfg.pre_id then
								task_pre_data = v1
								break
							end
						end
						if task_pre_data then
							keep_off_flag = true
							break
						end
						task_pre_cfg = task_data_season_tab[task_pre_cfg.pre_id]
					end

					if keep_off_flag == false then
						table.insert(self.m_union_task_data, task_item)
					end
				end

			end
		end
	end

	table.sort(self.m_mine_task_data, function(item1, item2)
		if item1.status == item2.status then
			return item1.id < item2.id
		else
			return item1.status > item2.status
		end
	end)
	table.sort(self.m_union_task_data, function(item1, item2)
		if item1.status == item2.status then
			return item1.id < item2.id
		else
			return item1.status > item2.status
		end
	end)

end

function M:updateTaskData(data)
	table.merge(self.m_data.quests, data.quests or {})
	table.merge(self.m_data.guild_quests, data.guild_quests or {})
	table.merge(self.m_explore_done_data, data.explore_done or {})
	self:initTaskData()
	self:initExploreData()
	self:updateRedPointStatus()
end

function M:updateTaskDataRewardStatus(task_key, task_ID, reward_status)
	local task_data = {}
	if task_key == self.m_task_tag_mine then
		task_data = self.m_mine_task_data
	elseif task_key == self.m_task_tag_union then
		task_data = self.m_union_task_data
	end
	for _, v in pairs(task_data) do
		if v.cfg.id == task_ID then
			v.status = reward_status
			break
		end
	end
end

function M:getTaskData(task_key)
	if task_key == self.m_task_tag_mine then
		return self.m_mine_task_data or {}
	elseif task_key == self.m_task_tag_union then
		return self.m_union_task_data or {}
	end
	return {}
end

--探索进度--
function M:updateExploreDoneData(data)
	table.merge(self.m_explore_done_data, data)
	self:initExploreData()
	self:updateRedPointStatus()
end

function M:initExploreData()
	self.m_explore_data = {}
	local cur_season = UserDataManager:getCurSeason()
	local gve_tab = ConfigManager:getCfgByName("gve") or {}
	local gve_season_tab = gve_tab[cur_season] or {}
	local gve_explore_score_tab = gve_season_tab.explore_scale or {}
	local gve_explore_reward_tab = gve_season_tab.explore_reward or {} 
	
	for k,v in pairs(gve_explore_score_tab) do
		local score = v
		local status = 0
		if table.keyof(self.m_explore_done_data, k) then
			status = 2	-- 已领取
		else
			if self.m_explore_value >= score then
				status = 1 -- 可领取
			else
				status = 0 -- 未完成
			end
		end
		table.insert(self.m_explore_data, {id = k, score = score, status = status, reward = {gve_explore_reward_tab[k]} or {}})
	end
	table.sort(self.m_explore_data, function(data1, data2)
		return data1.score < data2.score
	end)
end

function M:getExploreData()
	return self.m_explore_data, self.m_explore_value
end

function M:getExploreValue()
	return self.m_explore_value
end

--判断红点
function M:updateRedPointStatus()
	self.m_red_point_flag_mine = false
	self.m_red_point_flag_union = false
	self.m_red_point_flag_explore = false
	for k, v in pairs(self.m_mine_task_data) do
		if v.status == 1 then
			self.m_red_point_flag_mine = true
			break
		end
	end
	for k, v in pairs(self.m_union_task_data) do
		if v.status == 1 then
			self.m_red_point_flag_union = true
			break
		end
	end
	for k, v in pairs(self.m_explore_data) do
		if v.status == 1 then
			self.m_red_point_flag_explore = true
			break
		end
	end
	if self.m_red_point_flag_mine == false and self.m_red_point_flag_union == false and self.m_red_point_flag_explore == false then
		UserDataManager:removeRedDotByKey("gve_quest")
	end
end

function M:hasTaskMineReward()
	return self.m_red_point_flag_mine
end

function M:hasTaskUnionOrExploreReward()
	return self.m_red_point_flag_union or self.m_red_point_flag_explore
end

function M:hasTaskMineOrUnionReward()
	if self.m_select_tab_index == 1 then
		return self.m_red_point_flag_mine
	else
		return self.m_red_point_flag_union or self.m_red_point_flag_explore
	end
end

function M:setExploreProgressLoopScrollPosition(position)
	self.m_explore_progress_loopScroll_position = position
end

function M:getExploreProgressLoopScrollPosition()
	return self.m_explore_progress_loopScroll_position
end


return M
