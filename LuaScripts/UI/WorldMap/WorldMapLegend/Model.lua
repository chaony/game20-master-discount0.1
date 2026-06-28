local M = class("WorldMapLegendModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.task_table = ConfigManager:getCfgByName("regional_task")
	self.task_team_table = ConfigManager:getCfgByName("regional_task_team")
	self.map_table = ConfigManager:getCfgByName("regional_map")
	self.map_info_table = ConfigManager:getCfgByName("worldsceneevent_info")
	self.map_area_table = {}
	local map_area_tab = ConfigManager:getCfgByName("map_area")
	for k, v in pairs(map_area_tab) do
		if (map_area_tab[k].season and map_area_tab[k].season <= UserDataManager.m_season_data.season) or k == 91 then --地图都进来了，至少开一个地图吧
			self.map_area_table[k] = map_area_tab[k]
		end
	end
	
	self.m_area_id = self.m_params.area_id
	self.cur_area_id = self.m_area_id
	self.m_select_index = nil
	self.m_map_task = {}
	self:initMapTask()
	self:refreshArea()
	self:getMapData()
	
	self:refreshSelectIndex()
end

function M:refreshSelectIndex()
	self.m_select_index = nil
	local map_event = UserDataManager:getTasksData()
	--if table.nums(map_event) > 0 then
		for k,v in ipairs(self.m_allMap or {}) do
			if SceneManager.curScene.cur_map ~= nil and v.id == SceneManager.curScene.cur_map.map_id and SceneManager.curScene.cur_map.day_unlock == true then
				self.m_select_index = k
				break
			end
		end
	--end
end

function M:getMapData()
	local allMap = {}
	for k,v in pairs(self.map_info_table) do
		if v.sceneName == self.cur_area_id and v.type == 1 then
			if self.map_table[v.value] ~= nil then
				local map_name = self.map_table[v.value].name
				local task_count, total_task_count = self:getMapCpd(v.value)
				--if self.m_map_task[v.value] then
				--	task_count = task_count + 1
				--end
				table.insert(allMap, {id = v.value, name = map_name, task_count = task_count, total_task_count = total_task_count})
			end
		end 
	end
	table.sort(allMap, function(a,b) 
		local map1 = self.map_table[a.id]
		local map2 = self.map_table[b.id]
		return map1.stage_open < map2.stage_open
	end)
	self.m_allMap = allMap
end

function M:getMapCpd(map_id)
	local regional_task_done = UserDataManager:getRegionalTaskDoneData()
	local task_count = 0
	local area = regional_task_done[tostring(self.cur_area_id)]
	if area ~= nil then
		local scene = area.scenes[tostring(map_id)]
		if scene ~= nil then
			for k,v in pairs(scene.tasks) do
				local task = self.task_table[v]
				if task ~= nil and task.task_count ~= 1 then
					task_count = task_count + 1
				end
			end
		end
	end
	local map_data = self.map_table[map_id]
	
	return task_count, map_data.regional
end

function M:refreshArea()
	self.next_area_id = nil
	self.previous_area_id = nil
	for k,v in pairs(self.map_area_table) do
		if k < self.cur_area_id and (self.previous_area_id == nil or k > self.previous_area_id) then
			self.previous_area_id = k
		end
		if k > self.cur_area_id and (self.next_area_id == nil or k < self.next_area_id) then
			self.next_area_id = k
		end
	end
	if self.previous_area_id ~= nil then
		local open = GameUtil:getStageUnlock(self.map_area_table[self.previous_area_id].unlock)
		if open == false then
			self.previous_area_id = nil
		end
	end
	if self.next_area_id ~= nil then
		local open = GameUtil:getStageUnlock(self.map_area_table[self.next_area_id].unlock)
		if open == false then
			self.next_area_id = nil
		end
	end
end

--获取进行中任务
function M:getTaskData(map_id)
	local show_data = {}
	local event_id = self.m_map_task[map_id]
	if event_id then
		local map_event = UserDataManager:getTasksData()
		if map_event[event_id] then
			for i,v in ipairs(map_event[event_id].done) do
				table.insert(show_data, {id = v, map_id = map_id, finish = true})
			end
		end
		table.insert(show_data, {id = tonumber(event_id), map_id = map_id, finish = false})
	else
		local regional_task_done = UserDataManager:getRegionalTaskDoneData()
		local area = regional_task_done[tostring(self.cur_area_id)]
		if area ~= nil then
			local scene = area.scenes[tostring(map_id)]
			if scene ~= nil then
				for i,v in ipairs(scene.tasks) do
					table.insert(show_data, {id = v, map_id = map_id, finish = true})
				end
			end
		end
	end
	return show_data
end

--获取任务奖励
function M:getTaskReward(map_id)
	local rewards = {}
	local task_id = {}
	for k, v in pairs(self.task_team_table) do
		if v.map_id == map_id then
			task_id = v.task_id
			break
		end
	end
	if #task_id >= 2 then
		local lastTask_id = task_id[2]
		local lastTask = self.task_table[lastTask_id]
		if lastTask then
			rewards = lastTask.item_reward or {}
		end
	end
	return rewards
end

--获取任务链描述
function M:getTaskDescribe(map_id)
	for k, v in pairs(self.task_team_table) do
		if v.map_id == map_id then
			return v.task_describe
		end
	end
end

function M:initMapTask()
	local map_event = UserDataManager:getTasksData()
	for k,v in pairs(map_event) do
		local task_cfg = self.task_table[tonumber(k)]
		local map_id = self:getMotherMapId(task_cfg.chapter)
		self.m_map_task[map_id] = k
	end
end

--获取任务根场景id
function M:getMotherMapId(id)
	local map_table = ConfigManager:getCfgByName("regional_map")

	if map_table[id] ~= nil then
		local mother_map_id = map_table[id].mother_map_id
		if mother_map_id > 0 then
			return self:getMotherMapId(mother_map_id)
		end
	end
	return id
end

return M
