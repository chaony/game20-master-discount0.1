local M = class("WorldMapMainView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapMain"
M.m_iphoneXAdapter = true

local OPEN_BTN_TAB = {
	--{ btn_key = "prestige_btn", open_id = 100, lock = true}, --威望
	{ btn_key = "bag_btn", open_id = 90, lock = true}, --行囊
	{ btn_key = "qy_btn", open_id = 91, lock = true}, --奇遇
	{ btn_key = "completion_reward_btn", open_id = 92, lock = true}, --游记
	{ btn_key = "travels_btn", open_id = 92, lock = true}, --探索
	--{ btn_key = "xs_btn", open_id = 93, lock = true}, --悬赏
	--{ btn_key = "zd_btn", open_id = 94, lock = true}, --驻地
}


function M:onEnter()
	M.super.onEnter(self)
	self:setTextByLanKey("close_title_text", "world_str_007")
	self:setTextByLanKey("task_title_text", "new_str_0523")
	
	self:setTextByLanKey("qy_btn_text", "new_str_0360")
	self:setTextByLanKey("bag_btn_text", "new_str_0359")
	self:setTextByLanKey("completion_btn_text", "new_str_0603")
	self:setTextByLanKey("travels_btn_text", "new_str_0604")

	self.task_table = ConfigManager:getCfgByName("regional_task")
	self.task_team_table = ConfigManager:getCfgByName("regional_task_team")
	self.map_table = ConfigManager:getCfgByName("regional_map")
	self.task_hide = self:findGameObject("task_show_btn")
	self.task_show = self:findGameObject("task")
	self.m_gray_image = self:findImage("gray_img")
	self.m_encounter_event_time_text = self:findText("encounter_event_time_text")
    --local PlayerAttrNode = CustomRequire("UI.Common.PlayerAttrNode")
    --self.m_player_attr_node = PlayerAttrNode.new(self.m_control)
	self:refreshRedPoint()
	self:refreshTabNode()
	self:InitMsg()
	self:refreshEncounterMapEvent()
	self:visibleEncounterEventBtn(false)
	--self:updateEventLoopScroll()
	self:setObjectVisible("task_node", false)

	--快速导航
	self:setObjectVisible("guide_btn", true)

	local map_id = UserDataManager:getBattleStage()
	if map_id then
		--local num = self.m_model:getStageNumByChapter(map_id)
		local stage_tab = ConfigManager:getCfgByName("stage")
		local str = Language:getTextByKey(stage_tab[map_id].map_point_name)
		local change_text = Language:getTextByKey("new_str_0587", str)
		self:setTextByLanKey("challenge_btn_text", change_text)
	end
end

function M:refreshTitle(sceneId)
	local map_area_table = ConfigManager:getCfgByName("map_area")
	if map_area_table[sceneId] then
		self:setTextByLanKey("map_title_text", map_area_table[sceneId].name)
	else
		Logger.logError(sceneId, "refreshTitle map_area key not found : ")
	end
	local taskDownData = UserDataManager:getRegionalTaskDoneData()
	local cpd = 0
	if taskDownData ~= nil and taskDownData[tostring(sceneId)] ~= nil then
		cpd = taskDownData[tostring(sceneId)].cpd
	end
	self:setTextByLanKey("map_completion_text", cpd.."%")
end

function M:refreshTabNode()
	for k,v in pairs(OPEN_BTN_TAB) do
		local red_flag = BtnOpenUtil:isBtnOpen(v.open_id)
		local btn_obj = self:findGameObject(v.btn_key)
		local mask_obj = self:findGameObject(v.btn_key.."_mask")
		local back = UIUtil.findImage(btn_obj.transform)
		if mask_obj then
			mask_obj:SetActive(red_flag == false or v.lock == false)
		end
		if back then
			if red_flag == false or v.lock == false then
				back.color = Color.New(152/255, 152/255, 152/255)
			else
				back.color = Color.white
			end
		end
	end
end


function M:refreshRedPoint()
	--local red_point = UserDataManager:getRedDotByKey("big_map_reward")
	self:setObjectVisible("travels_btn_point_img", false)
	local com_red_point = false
	if SceneManager.curScene ~= nil and SceneManager.curScene.cur_map ~= nil and SceneManager.curScene.cur_map.day_unlock == true then
		local enter_map_list = UserDataManager:getTempData("enter_map_list") or {}
		local cur_map = SceneManager.curScene.cur_map
		com_red_point = cur_map.map_id ~= nil and cur_map.isDone == false and table.indexof(enter_map_list, cur_map.map_id) == false
	end
	self:setObjectVisible("completion_btn_point_img", com_red_point == true)
	--local pre_red_point = RedPointUtil:isFuncRedPointById(43)
	--self:setObjectVisible("bag_btn_point_img", pre_red_point == true)
end

function M:destroy()
	if self.m_player_attr_node then
		self.m_player_attr_node:destroy()
		self.m_player_attr_node = nil
	end
    M.super.destroy(self)
end


--刷新主界面的聊天内容
function M:RefreshChatInfo()
	if self.chat_sc_list_view == nil then
		return
	end
	local msgs = ChatUtil.msgs -- 聊天管理器中的聊天数据
	self.chat_sc_list_view:SetListItemCount(#msgs, false)
	self.chat_sc_list_view:MovePanelToItemIndex(#msgs-1, 0)
end


function M:InitMsg()
	if self.chat_sc_list_view ~= nil then
		self:RefreshChatInfo()
		return
	end
	local msgs = ChatUtil.msgs -- 聊天管理器中的聊天数据
	self.chat_sc_list_view = self:findGameObject('chat_sc'):GetComponent('LoopListView2')
	self.chat_sc_list_view:InitListView(#msgs,function(list, index)
		local msgs = ChatUtil.msgs -- 聊天管理器中的聊天数据
		if index < 0 or index>#msgs then
			return nil
		end
		local msg_data = msgs[index+1]
		local item

		item = list:NewListViewItem('text')
		local luaBehaviour = item:GetComponent('LuaBehaviour')
		local other_rt = item:GetComponent('RectTransform')
		local other_text =item:GetComponent('Text')
		other_text.text = '<color=yellow>'..msg_data.name..':</color>'
		if msg_data.channel_type == "3" then
			LuaBehaviourUtil.setImg(luaBehaviour,"chat_channel_img","a_gj_pindao_shijie","main_ui")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"chat_channel_text", "new_str_0476")
			other_text.text = other_text.text .. "<color=#66F470>" .. msg_data.msg .. "</color>"
		elseif msg_data.channel_type == "4" then
			LuaBehaviourUtil.setImg(luaBehaviour,"chat_channel_img","a_gj_pindao_xit","main_ui")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"chat_channel_text","new_str_0477")
			other_text.text = other_text.text .. "<color=#82ADED>" .. msg_data.msg .. "</color>"
		else
			other_text.text = other_text.text .. msg_data.msg
			if msg_data.channel_type == "1" then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"chat_channel_text","new_str_0475")
			else
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"chat_channel_text","new_str_0474")
			end
		end
		other_text:GetComponent('ContentSizeFitter'):SetLayoutVertical();
		local y = other_text:GetComponent('RectTransform').sizeDelta.y ;
		other_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), y)
		if not item.IsInitHandlerCalled then   
			item.IsInitHandlerCalled = true
		end
		return item
	end)
	self.chat_sc_list_view:MovePanelToItemIndex(#msgs-1, 0)
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
	self:setObjectVisible("task_node", #data > 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("task_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index , cell_data = cell_data})
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
	self.m_control:checkTaskGuide()
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
end

function M:setLimitTimeText(cell_data, luaBehaviour, text_key)
	if not IsNull(luaBehaviour) then
		local end_ts = cell_data.data.end_ts or 0
		local diff_time = end_ts - UserDataManager:getServerTime()
		local task_cell_btn = luaBehaviour:FindButton("task_cell_btn")
		if diff_time > 0 then
			local ft = GameUtil:formatTimeBySecond(diff_time)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, text_key or "limit_time_text", Language:getTextByKey("new_str_0485") .. ft)
			task_cell_btn.enabled = true
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, text_key or "limit_time_text", Language:getTextByKey("new_str_0486"))
			task_cell_btn.enabled = false
			self.m_control:setOnceTimer(1, function()
				self:refreshEncounterMapEvent()
			end)
		end
	end
end

function M:refreshEncounterMapEvent()
	self.m_model.m_cur_encounter_map_event = nil
	local data = self.m_model:getEncounterMapEventData()
	local show_flag = false
	local server_time = UserDataManager:getServerTime()
	for k,v in ipairs(data) do
		local end_ts = v.data.end_ts or 0
		local diff_time = end_ts - server_time
		if diff_time > 0 then
			--show_flag = true
			self.m_model.m_cur_encounter_map_event = v
			--self:setTextByLanKey("encounter_event_btn_text", v.team_cfg.team_name)
			self:setTextByLanKey("encounter_event_btn_text", "new_str_0556")
			self:setLimitTimeText(v, self.m_luaBehaviour, "encounter_event_time_text")
			local luaGameObjectUpdater = self.m_encounter_event_time_text:GetComponent("LuaGameObjectUpdater")
			luaGameObjectUpdater:RegistLuaUpdate(function(dt, undt)
				self:setLimitTimeText(v, self.m_luaBehaviour, "encounter_event_time_text")
			end, 1)
			break
		end
	end
    --self:setObjectVisible("encounter_event_btn", show_flag)
end

function M:visibleEncounterEventBtn(show_flag)
	show_flag = false
	self:setObjectVisible("encounter_event_btn", show_flag)
	if show_flag then
		audio:SendEvtUI("UI_QiYu")
	end
end

return M