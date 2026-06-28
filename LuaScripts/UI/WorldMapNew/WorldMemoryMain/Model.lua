local M = class("WorldMemoryMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("new_big_map_index")
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateHandler})
end

function M:onEnter()
	self.curSceneId = SceneManager.SceneID.HangUpScene -- 只有一个场景
	self.map_table = ConfigManager:getCfgByName("new_regional_map")
	self.regional_task_team_cfg = ConfigManager:getCfgByName("new_regional_task_team")
	self.regional_task_cfg = ConfigManager:getCfgByName("new_regional_task")
	self.article_opt_table = ConfigManager:getCfgByName("new_regional_article_option")
	self:refreshData(self.m_data)
end

-- 刷新数据
function M:refreshData(data)
	UserDataManager:setNewMapTasksData(data.tasks)
	UserDataManager:setNewMapCloseOptionData(data.closeoption)
	UserDataManager:setNewMapDelegationData(data.delegation_ids)
	UserDataManager:setNewMapSceneLineData(data.scene_lines)
	UserDataManager:setNewMapOngoingTaskData(data.ongoing_task)
	UserDataManager:setNewMapRegionalTaskDoneData(data.regional_task_done)
	UserDataManager:setNewMapAttrsData(data.attrs)
	UserDataManager:setNewMapPuzzleGroupsData(data.puzzle_groups)
	UserDataManager:setNewMapPuzzleIdsData(data.puzzle_ids)
	UserDataManager:setNewMapHourData(data.hour)
	UserDataManager:setNewMapWeatherData(data.weather)
	self.m_complete_chapter = UserDataManager:getNewMapPuzzleGroupsData() -- 完成的章节
	self.m_complete_stage = UserDataManager:getNewMapPuzzleIdsData() -- 完成的关卡

	self.m_chapter = self:getCurChapter() -- 进行中的章节
	self.m_stage = self:getCurStage() -- 进行中的关卡
	self.m_sel_chapter = self.m_chapter -- 默认选中当前的进行的组
	self.m_sel_stage = self.m_stage -- 默认选中当前的进行的关卡
	self:syncTrackTaskData()
	self:initData()
end

-- 初始化界面走一次
function M:initData()
	local groupList = self:getGroupIdList()
	local taskList = self:getTasksIdListByGroup(self.m_sel_chapter)
	self.m_sel_tab_index = table.indexof(groupList, self.m_sel_chapter) or 1 -- 选择的章节
	self.m_sel_stage_index = table.indexof(taskList, self.m_sel_stage) or 1 -- 选择的关卡
end

-- 检查章节是否开启
function M:checkChapterIsOpen(id)
	local state = 2 -- 0 未开启 1 进行中 2已完成
	local index = table.indexof(self.m_complete_chapter, id)
	if not index and id ~= self.m_chapter then
		state = 0
	end
	if id == self.m_chapter then
		state = 1
	end
	return state
end

-- 检查关卡是否开启
function M:checkStageIsOpen(id)
	local state = 2 -- 0 未开启 1 进行中 2已完成
	local lock_text = ""
	local index = table.indexof(self.m_complete_stage, id)
	if not index and id ~= self.m_stage then
		state = 0
		lock_text = Language:getTextByKey("world_memory_str_005")
	end
	if id == self.m_stage then
		state = 1
	end
	if index and id == self.m_stage then -- 进行中已完成的关卡
		state = 2
	end
	local lock_flag1, lock_text1 = self:checkStageCanOpen(id)
	if lock_flag1 then
		return 0, lock_text1
	end
	local lock_flag2, lock_text2 = self:checkAttr(id)
	if lock_flag2 then
		return 0, lock_text2
	end
	return state, lock_text
end

function M:checkStageCanOpen(id)
	local lock_flag, lock_text = false, ""
	local task_main_cfg = ConfigManager:getCfgByName("new_regional_task_main")
	local task_list_cfg = task_main_cfg[self.m_sel_chapter] or {}
	local tack_cfg = task_list_cfg[id]
	if tack_cfg then
		lock_flag, lock_text = ConfigManager:getQuestLockFlag(tack_cfg.stage)
		if lock_flag then
			return lock_flag, lock_text
		end
	end
	return lock_flag, lock_text
end

function M:checkAttr(id)
	local lock_flag, lock_text = false, ""
	local task_main_cfg = ConfigManager:getCfgByName("new_regional_task_main")
	local task_list_cfg = task_main_cfg[self.m_sel_chapter] or {}
	local tack_cfg = task_list_cfg[id]
	if tack_cfg then
		local need_attrs = tack_cfg.attr
		local need_attrs_list = {}
		for i, v in pairs(need_attrs) do
			local group, attr_id, cfg = self:getAttrGroupById(v)
			need_attrs_list[group] = {id = attr_id, name = cfg.name, name_lv = cfg.name_lv}
		end
 		local attr_list = UserDataManager:getNewMapAttrsData()
		local group_data_list = {}
		for i, v in pairs(attr_list) do
			group_data_list[tonumber(i)] = v.id
		end
		
		for group, attrId in pairs(group_data_list) do
			for group2, cfg in pairs(need_attrs_list) do
				if group == group2 then
					if attrId < cfg.id then -- 不满足条件
						lock_flag = true
						lock_text = lock_text .. Language:getTextByKey("world_memory_str_004",cfg.name, cfg.name_lv)
					end
				end
			end
		end
	end
	return lock_flag, lock_text
end

--获取属性配置
function M:getAttrConfigById(group, id)
	if not id then return end
	local new_regional_attr_cfg = ConfigManager:getCfgByName("new_regional_attr")
	for i, v in pairs(new_regional_attr_cfg) do
		for m, n in pairs(v) do
			if i == group and m == id then
				return n
			end
		end
	end
	return {}
end

function M:getAttrGroupById(id)
	if not id then return end
	local new_regional_attr_cfg = ConfigManager:getCfgByName("new_regional_attr")
	for i, v in pairs(new_regional_attr_cfg) do
		for m, n in pairs(v) do
			if m == id then
				return i, m, n -- i == group m == id n ==cfg
			end
		end
	end
	return
end

-- 获取当前进行的关卡
function M:getCurStage()
	local stageList = {}
	local stageList2 = {}
	local max_stage = 0
	local task_main_cfg = ConfigManager:getCfgByName("new_regional_task_main")
	local groupId = self:getCurChapter()
	local task_list_cfg = task_main_cfg[groupId] or {}
	for i, v in pairs(task_list_cfg) do
		if i > max_stage then
			max_stage = i
		end
		table.insert(stageList,i)
	end
	for i = #stageList, 1, -1 do
		for m, n in pairs(self.m_complete_stage) do
			if stageList[i] == n then
				stageList[i] = nil
			end
		end
	end
	for i, v in pairs(stageList) do
		table.insert(stageList2,v)
	end
	local function sortFun(data1, data2)
		return data1 < data2
	end
	table.sort(stageList2,sortFun)
	return stageList2[1] or max_stage -- 取当前关卡，取不到取最大关卡
end
-- 获取当前进行的章节
function M:getCurChapter()
	local groupList = {}
	local groupList2 = {}
	local max_group = 0
	local task_main_cfg = ConfigManager:getCfgByName("new_regional_task_main")
	for i, v in pairs(task_main_cfg) do
		if i > max_group then
			max_group = i
		end
		table.insert(groupList,i)
	end
	for i = #groupList, 1, -1 do
		for m, n in pairs(self.m_complete_chapter) do
			if groupList[i] == n then
				groupList[i] = nil
			end
		end
	end
	for i, v in pairs(groupList) do
		table.insert(groupList2,v)
	end
	local function sortFun(data1, data2)  
		return data1 < data2
	end
	table.sort(groupList2,sortFun)
	return groupList2[1] or max_group -- 取当前章节，取不到取最大章节
end

--获取拼图组配置
function M:getTaskMainConfigById(group_id)
	if not group_id then return end
	local task_main_cfg = ConfigManager:getCfgByName("new_regional_task_main")
	local task_cfg = task_main_cfg[group_id] or {}
	return task_cfg
end

function M:getTasksCfgListByGroup(group_id)
	if not group_id then return end
	local taskList = {}
	local task_cfg = self:getTaskMainConfigById(group_id)
	for i, v in pairs(task_cfg) do
		taskList[#taskList+1] = {id = i, cfg = v}
	end
	table.sort(taskList,function(data1,data2) return data1.id < data2.id  end)
	return taskList
end

function M:getTasksIdListByGroup(group_id)
	if not group_id then return end
	local taskIdList = {}
	local task_cfg = self:getTaskMainConfigById(group_id)
	for i, v in pairs(task_cfg) do
		taskIdList[#taskIdList+1] = i
	end
	table.sort(taskIdList,function(data1,data2) return data1 < data2 end)
	return taskIdList
end

-- 获取章节配置
function M:getChapterCfgById(group_id)
	if not group_id then return end
	local taskList = {}
	local task_cfg = self:getTaskMainConfigById(group_id)
	for i, v in pairs(task_cfg) do
		taskList = v
		break
	end
	return taskList
end

function M:getGroupIdList()
	local groupIdList = {}
	local task_main_cfg = ConfigManager:getCfgByName("new_regional_task_main")
	for i, v in pairs(task_main_cfg) do
		table.insert(groupIdList,i)
	end
	table.sort(groupIdList,function(data1,data2) return data1 < data2  end)
	return groupIdList
end

function M:getBattleEndDramaId(result)
	local event_id = UserDataManager:getTempData("new_map_battle_event_id")
	local event_type = UserDataManager:getTempData("new_map_battle_event_type")
	local drama_id = 0
	if event_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then
		local encounter_cfg = ConfigManager:getCfgByName("encounter")
		local item_cfg = encounter_cfg[event_id] or {}
		drama_id = result == 1 and item_cfg.event_after or item_cfg.defeat_id
	end
	return drama_id or 0
end

function M:getRegionalTaskData()
	local regional_task_cfg = ConfigManager:getCfgByName("new_regional_task")
	local map_event = UserDataManager:getNewMapOngoingTaskData()
	local show_data = {}
	for k, v in pairs(map_event) do
		for k1,v1 in pairs(v) do  -- "101": [1]  # 场景id: [任务id]   地图id和npc的id对应
			local regional_task_cfg_item = regional_task_cfg[v1]
			if regional_task_cfg_item then
				table.insert(show_data, {data = {event_id = v1}, cfg = regional_task_cfg_item, npc_id = tonumber(k), event_type = GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT})
			end
		end
	end
	return show_data
end

---获取主线任务
function M:getMainTaskData()
	local map_event = UserDataManager:getNewMapTasksData()
	local show_data = {}
	for k, v in pairs(map_event) do
		local regional_task_cfg_item = self.regional_task_cfg[tonumber(k)]
		local task_team = self.regional_task_team_cfg[regional_task_cfg_item.tasks_types]
		if task_team and task_team.tasks_types == 1 then
			if v.status == 5 then
				local opt_id = regional_task_cfg_item.option_id
				local opt = self.article_opt_table[opt_id[1]]
				if opt ~= nil then
					local task = self.regional_task_cfg[opt.start_event]
					table.insert(show_data, {task_team_id = task.tasks_types, task_id = opt.start_event, Photo_Resources = task.Photo_Resources, event_type = GlobalConfig.WORLD_MAP_EVENT.MAIN_EVENT, status = v.status})
				end
			else
				table.insert(show_data, {task_team_id = regional_task_cfg_item.tasks_types, task_id = tonumber(k), Photo_Resources = regional_task_cfg_item.Photo_Resources, event_type = GlobalConfig.WORLD_MAP_EVENT.MAIN_EVENT, status = v.status})
			end
		end
	end
	return show_data
end

--获取支线任务
function M:getTrackBranchTaskData()
	local map_event = UserDataManager.local_data:getUserDataByKey("world_memory_track_task", { })
	local tasks = UserDataManager:getNewMapTasksData()
	local show_data = {}
	local isChange = false
	for k, v in pairs(map_event) do
		if tasks[tostring(v)] ~= nil then
			local regional_task_cfg_item = self.regional_task_cfg[v]
			local task_team = self.regional_task_team_cfg[regional_task_cfg_item.tasks_types]

			if task_team == nil or task_team.tasks_types ~= 1 then
				table.insert(show_data, {task_id = v, Photo_Resources = regional_task_cfg_item.Photo_Resources, event_type = GlobalConfig.WORLD_MAP_EVENT.BRANCH_EVENT})
			end
		else
			table.removebyvalue(map_event, v)
			isChange = true
		end
	end
	if isChange == true then
		UserDataManager.local_data:getUserDataByKey("world_memory_track_task", { })
	end
	return show_data
end

function M:syncTrackTaskData()
	local track_task = {}
	local update_data = UserDataManager:getNewMapTasksData()
	for k, v in pairs(update_data) do
		local task_id = tonumber(k)
		local task_team_id = self.regional_task_cfg[task_id].tasks_types
		local task_team = self.regional_task_team_cfg[task_team_id]
		track_task[tostring(task_team.map_id)] = task_id
	end
	UserDataManager.local_data:setUserDataByKey("world_memory_track_task", track_task)
end

function M:dataUpdateHandler(eventName, data)
	if data.event == "sync_map_task" then
		self:syncTrackTaskData()
		static_rootControl:closeView("Guide.GuideDrama")
		if  LikeOO.NewMap2DControl.curMap2D.m_cur_node ~= nil and IsNull(LikeOO.NewMap2DControl.curMap2D.m_cur_node.m_luaBehaviour) == false then
			LikeOO.NewMap2DControl.curMap2D:refreshUI()
			LikeOO.NewMap2DControl.curMap2D.m_cur_node:refreshTaskInfo()
		end
	end
end

--打开某个剧情
function M:transPointPoint(sceneId)
	if  self.map_table[sceneId] ~= nil and self.map_table[sceneId].stage_open > 0 then
		local open_flag, pre_task_end, tips_str = self:checkMapOpen(sceneId)
		if open_flag == true then
			if pre_task_end == true then
				static_rootControl:updateMsg("brand_btn", sceneId, "WorldMap.WorldMapMain")
				LikeOO.NewMap2DControl:openMap2D(sceneId)
			else
				GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
			end
		else
			GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
		end
	end
end

function M:checkMapOpen(map_id)
	local curDay = GameUtil:dayCompute()
	local unlock_days = self.map_table[map_id].unlock_days or 1
	local day_open_flag = curDay >= unlock_days
	local stage_open_flag, tips_str = GameUtil:getStageUnlock(self.map_table[map_id].stage_open)
	local mapName = self.map_table[map_id].name
	local pre_task_end = true
	local brand_str = tips_str

	if day_open_flag == false then
		if stage_open_flag == true then
			tips_str = Language:getTextByKey("worldMap_str_008", mapName, unlock_days - curDay)
			brand_str = Language:getTextByKey("worldMap_str_009", unlock_days - curDay)
		end
	else
		if stage_open_flag == true then
			if self.cur_map.map_id ~= nil and self.cur_map.map_id ~= 0 then
				if map_id ~= self.cur_map.map_id and self.map_table[map_id].stage_open > self.map_table[self.cur_map.map_id].stage_open then
					pre_task_end = false
					tips_str = Language:getTextByKey("worldMap_str_007", self.map_table[self.cur_map.map_id].name)
				end
			end
		end
	end

	return stage_open_flag and day_open_flag, pre_task_end, tips_str, brand_str
end

function M:getMapIdByTaskLineId(line_id)
	if not line_id or not self.regional_task_team_cfg[line_id] then return end
	return self.regional_task_team_cfg[line_id].map_id
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateHandler})
	M.super.destroy(self)
end


return M
