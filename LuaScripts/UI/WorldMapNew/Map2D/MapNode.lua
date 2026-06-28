local M = class("MapNode",LikeOO.OOUIbase)

M.m_uiName = "NewMap/WorldMemoryMapNode"
M.m_iphoneXAdapter = true

local OPEN_BTN_TAB = {
	{ btn_key = "bag_btn", open_id = 302, lock = true}, --行囊
	{ btn_key = "completion_reward_btn", open_id = 303, lock = true}, --游记
	{ btn_key = "travels_btn", open_id = 304, lock = true}, --属性
}

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
	self.task_table = ConfigManager:getCfgByName("new_regional_task")
	self.task_team_table = ConfigManager:getCfgByName("new_regional_task_team")
	self.map_table = ConfigManager:getCfgByName("new_regional_map")
	self.npc_table = ConfigManager:getCfgByName("new_regional_npc")

	self:setTextByLanKey("bag_btn_text", "new_str_0359")
	self:setTextByLanKey("completion_btn_text", "new_str_0603")
	self:setTextByLanKey("travels_btn_text", "new_str_0434")
	self:setTextByLanKey("close_title_text", "new_str_0478")
	self:setTextByLanKey("back_btn_text", "world_str_007")

	self.map = self.m_params.map
	self.task_hide = self:findGameObject("task_show_btn")
	self.task_show = self:findGameObject("task")
	
	self.red_point = self:findGameObject("red_point")

	self.npc_obj = self:findGameObject("npc")
	self.path_obj = self:findGameObject("path_btn")
	self.close_obj = self:findGameObject("CommonCloseNode")
	self.bottom_obj = self:findGameObject("left_bottom")
	
	self.npc_loopscroll = self:findGameObject("npc_loopscroll")

	--互动物品读条资源
	self.loading_bg = self:findGameObject("loading_bg")
	if self.loading_bg ~= nil then
		self.loading = self:findImage("loading")
		self.loading_bg.gameObject:SetActive(false)
	end

	self:setText("map_title_text", self.map.map_table[self.map.map_id].name)

	--进入的场景
	local open_map = UserDataManager.local_data:getUserDataByKey("big_map_enter_map_new", {})
	
	if open_map[tostring(self.map.map_id)] ~= 1 then
		self:findNewArea()
		open_map[tostring(self.map.map_id)] = 1
	end
	UserDataManager.local_data:setUserDataByKey("big_map_enter_map_new", open_map)

	self:refreshRedPoint()
	self:refreshTabNode()
	self:refreshPathNode()
	--self:updateEventLoopScroll()
	self:refreshTaskInfo()
	
	self.taskFinish_anim = self:findSkeletonGraphic("task_finish");
	self:taskFinish(false)
	self:refreshUI()
	self:refreshWeatherTimeNode()
	self.time_weather_show = false
end

function M:refreshTabNode()
	for k,v in pairs(OPEN_BTN_TAB) do
		local red_flag = BtnOpenUtil:isBtnOpen(v.open_id)
		local btn_obj = self:findGameObject(v.btn_key)
		local mask_obj = self:findGameObject(v.btn_key.."_mask")
		local back = UIUtil.findImage(btn_obj.transform)
		--local img = UIUtil.findImage(btn_obj.transform, "img")
		if mask_obj then
			mask_obj:SetActive(red_flag == false or v.lock == false)
		end
		if back then
			if red_flag == false or v.lock == false then
				back.color = Color.New(152/255, 152/255, 152/255)
				--img.color = Color.New(152/255, 152/255, 152/255)
			else
				back.color = Color.white
				--img.color = Color.white
			end
		end
	end
end

function M:refreshPathNode()
	local scene_lines_data = UserDataManager:getNewMapSceneLineData()
	if scene_lines_data ~= nil then
		local area_id = UserDataManager.local_data:getUserDataByKey("world_memory_area_id",101)
		local area = scene_lines_data[tostring(area_id)]
		if area ~= nil then
			self.scene_lines = area[tostring(self.map.motherMapId)]
		end
	end
	self.scene_lines = self.scene_lines or {}
	local curMaps = self.map:getCurTaskMaps()

	local path_mask = self:findGameObject("path_mask")
	if self.route_obj == nil then
		self.route_obj = ResourceUtil:LoadUIGameObject("NewMap/MapRoute/Route"..self.map.motherMapId, Vector3.zero, path_mask)
	end
	if self.route_obj ~= nil then
		local route_tran = self.route_obj:GetComponent("RectTransform")
		local canvas_group = self.route_obj:GetComponent("CanvasGroup")
		canvas_group.alpha = 0.2
		route_tran.localScale = Vector3.New(0.5,0.5,0.5)

		local current = nil

		for i = 1, route_tran.childCount do
			local child = route_tran:GetChild(i - 1)
			if string.find(child.name, "map") ~= nil then
				local luaBehaviour = UIUtil.findLuaBehaviour(child)
				if luaBehaviour ~= nil then
					local name = string.split(child.name, '_')
					local map_id = tonumber(name[2])

					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bottom", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "opened_text", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unopened_text", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_WorldMap_BiaoZhi_001", curMaps[map_id] ~= nil)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_WorldMap_BiaoZhi_002", curMaps[map_id] ~= nil)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "map_btn", false)

					if self.map_table[map_id] ~= nil then
						if table.indexof(self.scene_lines, map_id) ~= false or self.map_table[map_id].initial_state == 1 then
							LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unopened", false)
							LuaBehaviourUtil.setObjectVisible(luaBehaviour, "opened", true)

							if map_id == self.map.map_id then
								current = child:GetComponent("RectTransform")
							end

							local path = UIUtil.findTrans(route_tran, "path_"..map_id)
							if path ~= nil then
								--for i = 1, path.childCount do
								--	local childPath = path:GetChild(i - 1)
								--	if table.indexof(self.scene_lines, tonumber(childPath.name)) ~= false then
								--		childPath.gameObject:SetActive(true)
								--	else
								--		childPath.gameObject:SetActive(false)
								--	end
								--end
							end
						else
							LuaBehaviourUtil.setObjectVisible(luaBehaviour, "opened", false)
							LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unopened_text", true)
							LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unopened_text", self:getMapName(map_id))
							--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "path_"..map_id, false)
							--if self.map_table[map_id].initial_state == 2 then
							--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "opened", false)
							--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "question", false)
							--	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unopened_text", self:getMapName(map_id))
							--elseif self.map_table[map_id].initial_state == 3 then
							--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "opened", false)
							--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "question", true)
							--elseif self.map_table[map_id].initial_state == 4 then
							--	child.gameObject:SetActive(false)
							--end
						end
					end
				end
			elseif child.name == "bg" then
				child.gameObject:SetActive(false)
			end
		end

		local pos = route_tran.anchoredPosition
		pos.x = 0
		pos.y = 0
		if current ~= nil then
			pos.x = -current.anchoredPosition.x * route_tran.localScale.x
			pos.y = -current.anchoredPosition.y * route_tran.localScale.x
		end
		route_tran.anchoredPosition = pos
	end	
	
	--刷新detail_player节点
	self:setText("map_name_text", self.map_table[self.map.motherMapId].name)

	local map_tab = ConfigManager:getCfgByName("new_regional_map")
	local c_num = table.nums(self.scene_lines)
	local max_num = map_tab[self.map.motherMapId] and map_tab[self.map.motherMapId].scene or 0
	self:setText("map_complete_text", c_num.."/"..max_num)
	
	local cpd, status = self:getMapCpd()
	if status == 2 then
		LuaBehaviourUtil.setImg(self.m_luaBehaviour, "box_btn", "a_ck_linshixiangzi_open", "common_ui")
	else
		LuaBehaviourUtil.setImg(self.m_luaBehaviour, "box_btn", "a_ck_linshixiangzi", "common_ui")
	end
	LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "tx_box", status == 1)
	
end

function M:refreshUI()
	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:onButtonClick(obj, name)
	--回城
	if name == "back_btn" then
		self.m_control:updateMsg("guide_close_mapNode")
		LikeOO.NewMap2DControl:closeMap()
		--返回上一层
	elseif name == "close_btn" then
		self.m_control:updateMsg("guide_close_mapNode")
		LikeOO.NewMap2DControl:backToHigherMap()
		--返回挂机
	elseif name == "guide_btn" then
		self.m_control:updateMsg("guide_close_mapNode")
		--self.m_control:updateMsg(99999)
		LikeOO.NewMap2DControl:closeMap(false)
			--帮助界面
	elseif name == "help_btn" then
		local params = {}
		params.title = "new_str_0021"
		params.content = "tid#cathedral102002"
		self.m_control:openView("Pops.CommonHelpPop", params)
		--路线图界面
	elseif name == "path_btn" then
		self:onButtonClickPathBtn()
		--行囊
	elseif name == "bag_btn" then
		self.m_control:openView("Item.ItemList", {isShowRunescapeItem = true})
	elseif name == "completion_reward_btn" then
		local params = { area_id = UserDataManager.local_data:getUserDataByKey("world_memory_area_id",101), map_id = self.map.motherMapId}
		self:openView("WorldMapNew.WorldMemoryLegend", params)
	elseif name == "travels_btn" then
		self:openView("WorldMapNew.WorldMemoryAttrPop")
		--显示任务列表
	elseif name == "task_show_btn" then
		self.task_show:SetActive(true)
		self.task_hide:SetActive(false)
		--隐藏任务列表
	elseif name == "task_hide_btn" then
		self.task_show:SetActive(false)
		self.task_hide:SetActive(true)
	--完成奖励宝箱	
	elseif name == "box_btn" then
		local cpd, status = self:getMapCpd()
		if status == 1 then
			-- 领取场景完成度奖励
			local function netCallback(response)
				self:refreshPathNode()
				RewardUtil:rewardTipsByData(response.reward)
				if response.update_attrs ~= nil and _G.next(response.update_attrs) then
					local tips = UserDataManager:checkWorldMemoryAttrUpdate(response.update_attrs)
					TimeTools:delayTimeUnity(0.5,
							function()
								GameUtil:lookInfoTips(static_rootControl, {msg = tips, delay_close = 2})
							end)
				end
			end
			local params = {area_id = UserDataManager.local_data:getUserDataByKey("world_memory_area_id",101), scene_id = self.map.motherMapId}
			self.m_model:getNetData("new_big_map_receice_scene_cpd", params, netCallback)
		else
			self:onButtonClickPathBtn()
		end

	elseif name == "time_weather_btn" then
		if self.time_weather_show then
			self.time_weather_show = false
		else
			self.time_weather_show = true
		end
		self:showTimeWeatherNode(self.time_weather_show)
	end

	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:onButtonClickPathBtn()
	self.m_control:updateMsg("path_btn")
	local params = {}
	params.area_id = UserDataManager.local_data:getUserDataByKey("world_memory_area_id",101)
	params.scene_id = self.map.motherMapId
	params.mode = 2
	self:openView("WorldMapNew.WorldMapTaskReward", params)
end

function M:startLoading(finish)
	if self.loading_bg ~= nil then
		self.loading.fillAmount = 0
		self.loading_bg:SetActive(true)
		self.loadingId = self.m_control:setTimer(0.033, function()
			if self.loading.fillAmount >= 1 then
				self.loading_bg:SetActive(false)
				self.m_control:removeTimer(self.loadingId)
				finish()
				self.loadingId = nil
			else
				self.loading.fillAmount = self.loading.fillAmount + 0.033
			end
		end)
	else
		finish()
	end
end

--刷新任务进度
function M:refreshProgress(value)
	if self.progressText == nil then
		self.progressText = self:findText("progress_num")
	end
	local num = math.floor(value * 100)
	self.progressText.text = num.."%"
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if  curEvent == "new_task_done_update" then
		self:refreshRedPoint()
		self:refreshPathNode()
	elseif curEvent == "weather_hour_update" then
		self:refreshWeatherTimeNode()
	end
end

function M:refreshWeatherTimeNode()
	local new_regional_time_cfg = ConfigManager:getCfgByName("new_regional_time")
	local new_regional_weather_cfg = ConfigManager:getCfgByName("new_regional_weather")
	local weatherId = UserDataManager:getNewMapWeatherData()
	local timeId = UserDataManager:getNewMapHourData()
	if new_regional_time_cfg[timeId] and new_regional_weather_cfg[weatherId] then
		local hour_name = new_regional_time_cfg[timeId].name
		local weather_name = new_regional_weather_cfg[weatherId].name
		local weather_des = new_regional_weather_cfg[weatherId].des
		self:setTextByLanKey("time_title_text", Language:getTextByKey(tostring(hour_name)).. " "..Language:getTextByKey(tostring(weather_name)))
		self:setTextByLanKey("weather_des",Language:getTextByKey(tostring(weather_des)))
		local remaining_time = (24 - tonumber(timeId))/2
		if tostring(remaining_time) == "0.0" then
			remaining_time = 0
		end
		self:setTextByLanKey("time_cutdown_text", Language:getTextByKey("world_memory_str_010",tostring(remaining_time)))
	end
end

function M:showTimeWeatherNode(show)
	self:setObjectVisible("weather_node", show)
end

function M:closeViewEvent(event, data)
	local view_name = data.name or ""
	if view_name == "Loading.SyncLoadBigLoading" then
		self:updateMsg("auto_open_func")
	elseif view_name == "Item.ItemList" then
		if self.m_view then
			self.m_view:refreshRedPoint()
			self:refreshRedPoint()
		end
	end
end

function M:refreshRedPoint()
	if IsNull(self.m_luaBehaviour) == false then
		--local red_point = RedPointUtil:hasRedPointById(5001)
		self:setObjectVisible("travels_btn_point_img", false)
		--local pre_red_point = RedPointUtil:isFuncRedPointById(43)
		--self:setObjectVisible("bag_btn_point_img", pre_red_point)
		local com_red_point = false
		if SceneManager.curScene ~= nil and SceneManager.curScene.cur_map ~= nil and SceneManager.curScene.cur_map.day_unlock == true then
			local enter_world_memory_list = UserDataManager:getTempData("enter_world_memory_list") or {}
			local cur_map = SceneManager.curScene.cur_map
			com_red_point = cur_map.map_id ~= nil and cur_map.isDone == false and table.indexof(enter_world_memory_list, cur_map.map_id) == false
		end
		self:setObjectVisible("completion_btn_point_img", com_red_point == true)
	end
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

function M:getMapCpd()
	local regional_task_done = UserDataManager:getNewMapRegionalTaskDoneData()
	local cpd = 0
	local status = 0 -- 0：未完成，1：可领取，2：已领取
	if regional_task_done then
		local area_id = UserDataManager.local_data:getUserDataByKey("world_memory_area_id",101)
		local area = regional_task_done[tostring(area_id)]
		if area ~= nil then
			local scene = area.scenes[tostring(self.map.motherMapId)]
			if scene ~= nil then
				cpd = scene.cpd or 0
				status = scene.status or 0
			end
		end
	end
	
	return cpd, status
end

--[[
	创建列表
]]
function M:updateEventLoopScroll()
	local main_data = self.m_model:getMainTaskData()
	local branch_data = self.m_model:getTrackBranchTaskData()
	local data = {}
	for k,v in pairs(main_data) do
		table.insert(data, v)
	end
	for k,v in pairs(branch_data) do
		table.insert(data, v)
	end
	--self:setObjectVisible("task_node", #data > 0)
	self:setObjectVisible("task_node", false)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("task_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local task = self.task_table[cell_data.task_id]
				if cell_data.status == 5 then
					GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0600"), delay_close = 2})
				else
					local task_team = self.task_team_table[task.tasks_types]
					Logger.logError("WorldMapTask  用到了  没改！！！")
					self.m_control:openView("WorldMap.WorldMapTask.WorldMapEvents", {open_tab_index = task_team.tasks_types, task_id = cell_data.task_id})
				end

			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--刷新当前任务
function M:refreshTaskInfo()
	local track_task = UserDataManager.local_data:getUserDataByKey("world_memory_track_task", { })
	local show_task = track_task[tostring(self.map.motherMapId)]

	local task_info_obj = self:findGameObject("task_info")
	local luaBehaviour = task_info_obj:GetComponent("LuaBehaviour")
	if show_task ~= nil then
		task_info_obj:SetActive(true)

		local task = self.task_table[show_task]
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_name_text", task.event_name)

		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_story_text", task.event_mission)
		LuaBehaviourUtil.setTextColor(luaBehaviour, "task_story_text", GlobalConfig.COMMON_COLLOR.COMMON_1)
		luaBehaviour:RegistButtonClick(function (obj, name)
			local params = { area_id = UserDataManager.local_data:getUserDataByKey("world_memory_area_id",101), map_id = self.map.motherMapId}
			self:openView("WorldMapNew.WorldMemoryLegend", params)
		end)
		
		if self.map.newTasks ~= nil and table.indexof(self.map.newTasks, show_task) ~= false then
			self:addTask(task_info_obj)
		end
	else
		task_info_obj:SetActive(false)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local task = self.task_table[cell_data.task_id]

	local task_team = self.task_team_table[task.tasks_types]
	if task_team ~= nil and task_team.tasks_types == 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_name_text", "new_str_0580", Language:getTextByKey(task.event_name))
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_name_text", "new_str_0579", Language:getTextByKey(task.event_name))
	end
	if cell_data.status == 5 then
		local open_flag, tips_str = GameUtil:getStageUnlock(task.stage_id)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_story_text", tips_str)
		LuaBehaviourUtil.setTextColor(luaBehaviour, "task_story_text", GlobalConfig.COMMON_COLLOR.COMMON_19)
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_story_text", task.event_mission)
		LuaBehaviourUtil.setTextColor(luaBehaviour, "task_story_text", GlobalConfig.COMMON_COLLOR.COMMON_1)
	end
	if self.map.newTasks ~= nil and table.indexof(self.map.newTasks, cell_data.task_id) ~= false then
		self:addTask(cell_object)
	end
end

function M:taskFinish(show)
	self:setObjectVisible("task_finish", show)
	
	if show == true then
		self.taskFinish_anim.Skeleton:SetToSetupPose()
		self.taskFinish_anim.AnimationState:ClearTracks()
		self.taskFinish_anim.AnimationState:SetAnimation(0, "animation_1", false)
		self:addSpineComplete(self.taskFinish_anim.AnimationState, function() self:taskFinish(false)  end)

		--TimeTools:delayTime(1.5, function()
		--	self:taskFinish(false)
		--end)
	end
end

function M:addTask(parent)
	local com_parent = self:findGameObject("com")
	local lizi_01 = ResourceUtil:GetUIEffectItem("WorldMapMain/UI_WorldMapMain_LiuG_01", parent)
	local rect = lizi_01:GetComponent("RectTransform")
	rect.anchoredPosition3D = Vector3.New(0,0,0)
	--self:setSortingOrder(lizi_01)
	if self.m_control then
		self.m_control:setOnceTimer(1.5, function()
			U3DUtil:Destroy(lizi_01)
		end)
	end
end

function M:setSortingOrder(obj)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	if LuaBehaviour then
		local Par_liz_1 = LuaBehaviour:FindParticleSystem("fx_hit_01_2")
		local Par_liz_2 = LuaBehaviour:FindParticleSystem("fx_hit_01_3")
		local Par_liz_3 = LuaBehaviour:FindParticleSystem("hylz")
		Par_liz_1:GetComponent("Renderer").sortingOrder = self.m_sortOrder + 1
		Par_liz_2:GetComponent("Renderer").sortingOrder = self.m_sortOrder + 1
		Par_liz_3:GetComponent("Renderer").sortingOrder = self.m_sortOrder + 1
	end
end


--[[
	创建列表
]]
function M:updateNpcLoopScroll(data)
	if IsNull(self.npc_loopscroll) == false then
		self.npc_data = data or {}
		self:setObjectVisible("npc", #self.npc_data > 0)
		if self.m_npc_loop_scroll_view == nil then
			local params = {
				show_data = self.npc_data,
				loop_scroll_object = self.npc_loopscroll,
				update_cell = function(index, cell_object, cell_data)
					self:updateNpcScrollViewCell(index, cell_object, cell_data)
				end,
				click_func = function(index, cell_object, cell_data, click_object, click_name)
					self.map:onButtonClick(click_object, click_name)
				end
			}
			self.m_npc_loop_scroll_view = LoopScrollViewUtil.new(params)
		else
			self.m_npc_loop_scroll_view:reloadData(self.npc_data)
		end

		self.m_control:updateMsg("check_guide")
		--local common = ConfigManager:getCommonValueById(278)
		--if type(common) == "table" then
		--	local npc_data = self.m_npc_loop_scroll_view.m_show_data
		--	for i,v in ipairs(npc_data) do
		--		if v == common[2] then
		--			if self.map.tasks[common[2]].team_id ~= nil then
		--				UserDataManager.guide_data:setAnyTeamGuide(common[1])
		--				self.m_control:updateMsg("check_guide")
		--				break
		--			end
		--		end
		--	end
		--end
	end
end

--Scroll内cell的回调
function M:updateNpcScrollViewCell(index, cell_object, cell_data)
	local npc_id = cell_data
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_tips_text", self.npc_table[npc_id]["npc_name"])
	local hero_img = luaBehaviour:FindGameObject("tx_img")
	GameUtil:updateResourcesImg(hero_img, "Texture/HeroIcon/" .. self.npc_table[npc_id]["s_battle_icon"])
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", self.map.tasks[npc_id].team_id ~= nil)
	--local npc = cell_object.transform:GetChild(0)
	cell_object.name = "npc_"..npc_id
end

function M:findNewArea()
	local isParent, map = self:getMapName()
	if isParent == true then
		self:setObjectVisible("parentArea", true)
		self:setObjectVisible("childArea", false)
		self:setTextByLanKey("parentArea_text", "new_str_0601", map.name)
	else
		self:setObjectVisible("parentArea", false)
		self:setObjectVisible("childArea", true)
		self:setTextByLanKey("childArea_text", map.name)
		local area_img = self:findGameObject("area_img");
		GameUtil:updateResourcesImg(area_img, "Texture/map_bg/"..map.map_resource)
	end
	
	self.m_control:setOnceTimer(1.5, function()
		self:setObjectVisible("parentArea", false)
		self:setObjectVisible("childArea", false)
	end)
end

function M:getMapName()
	local map = self.map_table[self.map.map_id]
	local isParent = false
	if map ~= nil then
		isParent = self.map.map_id == self.map.motherMapId
	end
	return isParent, map
end

function M:ShowUI(show)
	if self.m_model == nil then
		return;
	end
	--self.npc_obj = self:findGameObject("npc")
	--self.path_obj = self:findGameObject("path_btn")
	--self.close_obj = self:findGameObject("CommonCloseNode")
	--self.bottom_obj = self:findGameObject("left_bottom")
	local npcShow = false
	if show == true then
		if self.npc_data ~= nil and #self.npc_data > 0 then
			npcShow = true
		end
	end
	self:setObjectVisible("npc", npcShow)
	self:setObjectVisible("path_btn", show)
	self:setObjectVisible("CommonCloseNode", show)
	self:setObjectVisible("left_bottom", show)
	local track_task = UserDataManager.local_data:getUserDataByKey("world_memory_track_task", { })
	local show_task = track_task[tostring(self.map.motherMapId)]
	self:setObjectVisible("task_info", show and show_task ~= nil)
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
	if self.route_obj ~= nil then
		ResourceUtil:ReturnItem(self.route_obj)
	end
	M.super.destroy(self)
end

return M
