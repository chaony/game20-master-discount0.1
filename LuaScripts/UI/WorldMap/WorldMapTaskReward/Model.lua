local M = class("WorldMapTaskRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_area_id = self.m_params.area_id
	self.m_scene_id = self.m_params.scene_id
	self.m_sel_tab_index = self.m_params.mode or 2
	self.m_open_tab_index = self.m_sel_tab_index
	self.main_task = self:getMainTaskTab() 
	self.article_opt_table = ConfigManager:getCfgByName("regional_article_option")
	self.mission_tab = ConfigManager:getCfgByName("regional_delegation")
	local task_tab = ConfigManager:getCfgByName("regional_task")
	local task_team_tab = ConfigManager:getCfgByName("regional_task_team")
	local map_event = UserDataManager:getTasksData()
	if self.m_open_tab_index == 1 then
		local data = self:getCurBanchTask()
		if #data <= 0 then
			self.m_open_tab_index = 2
		end
	end
	
	for k, v in pairs(map_event) do
		local regional_task_cfg_item = task_tab[tonumber(k)]
		local task_team = task_team_tab[regional_task_cfg_item.tasks_types]

		if task_team and task_team.tasks_types == 1 then
			if v.status == 5 then
				local opt_id = regional_task_cfg_item.option_id
				local opt = self.article_opt_table[opt_id[1]]
				if opt ~= nil then
					self.main_task_id = opt.start_event
				end
			else
				self.main_task_id = tonumber(k)
			end
			self.main_task_status = v.status
		end
	end
end

function M:getCurMainTask()
	local task_team_tab = ConfigManager:getCfgByName("regional_task_team")
	if task_team_tab[self.m_scene_id] then
		return task_team_tab[self.m_scene_id]
	end
	return nil
end

function M:getImgByTasks_types(id)
	local task_tab = ConfigManager:getCfgByName("regional_task")
	for k,v in pairs(task_tab) do
		if id == v.tasks_types then
			return v.Photo_Resources
		end
	end
	return "a_jh_tu23"
end

function M:getCurBanchTask()
	local data = {}
	local task_team_tab = ConfigManager:getCfgByName("regional_task_team")
	local task_tab = ConfigManager:getCfgByName("regional_task")
	local tasks = UserDataManager:getTasksData()
	local hasTask = {}
	for k,v in pairs(tasks) do
		local task_team_id = task_tab[tonumber(k)].tasks_types
		if task_team_tab[task_team_id].map_id == self.m_scene_id then
			table.insert(data, {id = task_team_id, data = v, task_id = k})
			hasTask[task_team_id] = 1
		end
	end
	--for k,v in pairs(task_team_tab) do
	--	if v.map_id == self.m_scene_id and hasTask[k] ~= 1 then
	--		table.insert(data, {id = k, data = v, task_id = v.task_id[1]})
	--	end
	--end
	if #data <= 0 then
		data = self:getBanchTask()
	end

	local function sortFunc(id_one, id_two)
        local id_1= id_one.id
        local id_2= id_two.id
		return id_1 < id_2
    end
    table.sort(data, sortFunc)
	return data
end

function M:getBanchTask()
	local data = {}
	local task_done = UserDataManager:getRegionalTaskDoneData()
	local task_team_tab = ConfigManager:getCfgByName("regional_task_team")
	local task_tab = ConfigManager:getCfgByName("regional_task")

	for k,v in pairs(task_done) do
		if tonumber(k) == self.m_area_id then
			for k1,v1 in pairs(v.scenes) do
				if tonumber(k1) == self.m_scene_id then
					if task_tab[tonumber(v1.tasks[#v1.tasks])] ~= nil then
						local task_team_id = task_tab[tonumber(v1.tasks[#v1.tasks])].tasks_types
						local cur_data = {done = table.copy(v1.tasks)}
						cur_data.done[#v1.tasks] = nil
						table.insert(data, {id = task_team_id, data = cur_data, task_id = v1.tasks[#v1.tasks]})
					end
				end
			end
		end
	end

	return data
end


function M:getBanchTaskNum()
	local max_num = 0
	local cur_num = 0
	local task = self:getCurBanchTask()
	local map_tab = ConfigManager:getCfgByName("regional_map")

	local task_done = UserDataManager:getRegionalTaskDoneData()
	local cur_task_done = task_done[tostring(self.m_area_id)]
	if cur_task_done ~= nil and cur_task_done.scenes[tostring(self.m_scene_id)] ~= nil then
		cur_num = table.nums(cur_task_done.scenes[tostring(self.m_scene_id)].tasks)
	end
	return cur_num.."/"..map_tab[self.m_scene_id].regional
end

function M:getBanchByIndex(index)
	local task_table = self:getCurBanchTask()
	return task_table[index]
end

function M:getMainTaskTab()
	local data = {}
	local task_team_cfg = self:getCurMainTask()
	if task_team_cfg and task_team_cfg.task_id then
		for k,v in pairs(task_team_cfg.task_id) do
			table.insert(data, v)
		end
	end
	local function sortFunc(id_one, id_two)
		return id_one < id_two
    end
    table.sort(data, sortFunc)
	return data
end

function M:getMainTaskNums()
	local task_team_cfg = self:getCurMainTask()
	local c_num = 0
	local max_num = task_team_cfg and table.nums(task_team_cfg.task_id) or 0 
	if task_team_cfg then
		if self.main_task_id > task_team_cfg.task_id[max_num] then
			return max_num.."/"..max_num
		else
			for i = 1, max_num do
				if self.main_task_id > task_team_cfg.task_id[i] then
					c_num = c_num + 1
				end
			end	
		end
	end
	return c_num.."/"..max_num
end

function M:getOpenSceneNums()
	local map_tab = ConfigManager:getCfgByName("regional_map")

	local scene_lines_data = UserDataManager:getSceneLineData()
	local scene_lines = {}
	if scene_lines_data ~= nil then
		local area = scene_lines_data[tostring(self.m_area_id)]
		if area ~= nil then
			scene_lines = area[tostring(self.m_scene_id)]
		end
	end
	scene_lines = scene_lines or {}
	
	local c_num = table.nums(scene_lines)
	local max_num = map_tab[self.m_scene_id] and map_tab[self.m_scene_id].scene or 0

	return c_num.."/"..max_num
end

function M:getMainTaskData(id)
	local task_tab = ConfigManager:getCfgByName("regional_task")
	return self.main_task_id > tonumber(id), task_tab[id]
end

function M:checkMainCom()
	local task_team_cfg = self:getCurMainTask()
	if task_team_cfg and task_team_cfg.task_id then
		for k,v in pairs(task_team_cfg.task_id) do
			if self.main_task_id <= v then
				return false
			end
		end
	end
	return true
end

function M:getMapCpd()
	local regional_task_done = UserDataManager:getRegionalTaskDoneData()
	local cpd = 0
	local status = 0 -- 0：未完成，1：可领取，2：已领取
	local area = regional_task_done[tostring(self.m_area_id)]
	if area ~= nil then
		local scene = area.scenes[tostring(self.m_scene_id)]
		if scene ~= nil then
			cpd = scene.cpd or 0
			status = scene.status or 0
		end
	end
	return cpd.."%", status
end

function M:getBranchTask(id)
	local task_done = UserDataManager:getRegionalTaskDoneData()
	local cur_task_done = task_done[tostring(self.m_area_id)] 
	local done = false
	if cur_task_done.scenes[tostring(self.m_scene_id)] ~= nil then
		for k,v in pairs(cur_task_done.scenes[tostring(self.m_scene_id)].tasks) do
			if id == v then
				done = true
				break
			end
		end
	end
	local task_tab = ConfigManager:getCfgByName("regional_task")
	return 	done, task_tab[tonumber(id)]
end

function M:getSenceReward()
	local task_tab = ConfigManager:getCfgByName("regional_map")
	local map_tab = task_tab[self.m_scene_id]
	return map_tab.item_reward
end

function M:getMissionData()
	local missions = self.mission_tab[self.m_scene_id]
	local delegationData = UserDataManager:getDelegationData()
	local missions_done = delegationData[tostring(self.m_scene_id)]
	local data = {}
	if missions ~= nil then
		for k,v in pairs(missions) do
			local done = false
			if missions_done ~= nil then
				done = table.indexof(missions_done, k)
			end
			table.insert(data, {id = k, cfg = v, done = done})
		end
	end
	table.sort(data, function(a,b) return a.id < b.id and a.done == false end)
	return data
end

function M:getMissionNums()
	local missions = self.mission_tab[self.m_scene_id]
	local delegationData = UserDataManager:getDelegationData()
	local missions_done = delegationData[tostring(self.m_scene_id)]
	local max_num = 0
	local c_num = 0
	if missions ~= nil then
		max_num = table.nums(missions)
	end
	if max_num > 0 then
		if missions_done ~= nil then
			c_num = table.nums(missions_done)
		end

		return c_num.."/"..max_num
	else
		return nil
	end
end

function M:getCurTaskMaps()
	local maps = {}
	local task_team_tab = ConfigManager:getCfgByName("regional_task_team")
	local task_tab = ConfigManager:getCfgByName("regional_task")
	local article_tab = ConfigManager:getCfgByName("regional_article")
	local tasks = UserDataManager:getTasksData()
	for k,v in pairs(tasks) do
		local task = task_tab[tonumber(k)]
		local task_team_id = task.tasks_types
		if task_team_tab[task_team_id].map_id == self.m_scene_id then
			if task.type == 1 or task.type == 2 then
				maps[task.chapter] = 1
			elseif task.type == 3 then
				for k,v in pairs(task.article_id) do
					local article = article_tab[v]
					maps[article.map_id] = 1

				end
			elseif task.type == 4 then
				for k,v in pairs(task.target) do
					local article = article_tab[v]
					maps[article.map_id] = 1
				end
			end
		end
	end
	return maps
end

return M
