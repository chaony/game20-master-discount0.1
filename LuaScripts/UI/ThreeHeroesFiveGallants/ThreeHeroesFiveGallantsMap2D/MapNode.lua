local M = class("MapNode",LikeOO.OOUIbase)

M.m_uiName = "ThreeHeroesFiveGallantsMap/MapNode"
M.m_iphoneXAdapter = true

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
	self.task_table = ConfigManager:getCfgByName("active_plot_task")
	self.task_team_table = ConfigManager:getCfgByName("active_plot_taskteam")
	self.map_table = ConfigManager:getCfgByName("active_plot_map")
	self.npc_table = ConfigManager:getCfgByName("active_plot_npc")
	
	self:setTextByLanKey("close_title_text", "new_str_0478")
	
	self.Map2DControl = self.m_params.Map2DControl

	self.map = self.m_params.map
	self.task_show = self:findGameObject("task")
	self.npc_obj = self:findGameObject("npc")
	self.close_obj = self:findGameObject("CommonCloseNode")
	self.bottom_obj = self:findGameObject("left_bottom")
	
	self.npc_loopscroll = self:findGameObject("npc_loopscroll")

	self:setText("map_title_text", self.map.map_table[self.map.map_id].name)
	
	self:refreshTaskInfo()
	
	self.taskFinish_anim = self:findSkeletonGraphic("task_finish");
	self:taskFinish(false)
	self:refreshUI()
end


function M:refreshUI()
	
end

function M:onButtonClick(obj, name)
	--回城
	if name == "back_btn" then
		self.m_control:updateMsg("guide_close_mapNode")
		self.Map2DControl:closeMap()
		--返回上一层
	elseif name == "close_btn" then
		self.m_control:updateMsg("guide_close_mapNode")
		self.Map2DControl:backToHigherMap()
		--返回挂机
	elseif name == "help_btn" then
		local params = {}
		params.title = "new_str_0021"
		params.content = "tid#cathedral102002"
		self.m_control:openView("Pops.CommonHelpPop", params)
	end

	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:closeViewEvent(event, data)
	local view_name = data.name or ""
	if view_name == "Loading.SyncLoadBigLoading" then
		self:updateMsg("auto_open_func")
	end
end

--刷新当前任务
function M:refreshTaskInfo()
	local track_task = UserDataManager.local_data:getUserDataByKey("track_task_activity", { })
	local show_task = track_task[tostring(self.map.motherMapId)]

	local task_info_obj = self:findGameObject("task_info")
	local luaBehaviour = task_info_obj:GetComponent("LuaBehaviour")
	if show_task ~= nil then
		task_info_obj:SetActive(true)
		local task = self.task_table[show_task]
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_name_text", task.event_name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_story_text", task.event_mission)
		LuaBehaviourUtil.setTextColor(luaBehaviour, "task_story_text", GlobalConfig.COMMON_COLLOR.COMMON_1)
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

function M:ShowUI(show)
	if self.m_model == nil then
		return;
	end
	local npcShow = false
	if show == true then
		if self.npc_data ~= nil and #self.npc_data > 0 then
			npcShow = true
		end
	end
	self:setObjectVisible("npc", npcShow)
	self:setObjectVisible("path_btn", false)
	self:setObjectVisible("CommonCloseNode", show)
	self:setObjectVisible("left_bottom", false)
	local track_task = UserDataManager.local_data:getUserDataByKey("track_task_activity", {})
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
