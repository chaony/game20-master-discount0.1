local M = class("WorldMapEventsView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapEvent/WorldMapEvents"
M.m_size_type = 2

local __TAB_BTN_NODE = {
	{btn_key = "going_btn", content_key = "going", btn_text = "going_btn_text", text_key = "new_str_0563"}, -- 进行中
	{btn_key = "done_btn", content_key = "done", btn_text = "done_btn_text", text_key = "new_str_0562"}, -- 已完成
}

function M:onEnter()
	self.regional_task_team_cfg = ConfigManager:getCfgByName("regional_task_team")
	self.regional_task_cfg = ConfigManager:getCfgByName("regional_task")
	self.regional_map_cfg = ConfigManager:getCfgByName("regional_map")
	self:setTextByLanKey("common_title_text", "worldMap_str_005")
	self:setTextByLanKey("none_reward_text", "new_str_0528")
	
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on)
			if is_on then
				self:updateMsg(k)
			end
		end, nil, self.m_uiName)
	end
	self:setObjectVisible("none_reward_text", false)
end

function M:switchTabNode(index)
	for k, v in pairs(__TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_5
	end
	local data = self.m_model:getTaskData()
	self:updateEventLoopScroll(data)
end

--[[
	创建列表
]]
function M:updateEventLoopScroll(data)
	self.m_sel_cell_obj = nil
	local data = data or {}
	if #data > 0 then
		if self.m_model.m_sel_tab_index == 1 and self.m_model.m_open_task_id ~= 0 then
			local cur_task = self.regional_task_cfg[self.m_model.m_open_task_id]
			for k,v in ipairs(data) do
				if v.task_team_id == cur_task.tasks_types then
					self.m_sel_cell_index = k
					break
				end
			end
		else
			self.m_sel_cell_index = 1
		end
	else
		self.m_sel_cell_index = nil
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("event_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if index ~= self.m_sel_cell_index then
					if self.m_sel_cell_obj then
						local luaBehaviour = UIUtil.findLuaBehaviour(self.m_sel_cell_obj)
						LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_select_img", false)
						LuaBehaviourUtil.setImg(luaBehaviour, "event_cell_btn", "a_jh_shijian_weixuanzhong", "main_ui")
					end
					self.m_sel_cell_index = index
					self.m_sel_cell_obj = cell_object
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_sel_cell_obj)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_select_img", true)
					LuaBehaviourUtil.setImg(luaBehaviour, "event_cell_btn", "a_jh_shijian_xuanzhong", "main_ui")
					self:updateMsg(click_name, {index = index , cell_data = cell_data})
				end	
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
	if self.m_sel_cell_index ~= nil then
		self:showEventInfo(data[self.m_sel_cell_index])
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if index == self.m_sel_cell_index then
		self.m_sel_cell_obj = cell_object
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_select_img", true)
		LuaBehaviourUtil.setImg(luaBehaviour, "event_cell_btn", "a_jh_shijian_xuanzhong", "main_ui")
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_select_img", false)
		LuaBehaviourUtil.setImg(luaBehaviour, "event_cell_btn", "a_jh_shijian_weixuanzhong", "main_ui")
	end
	
	local task_data = self.regional_task_cfg[cell_data.task_id]
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_name_text", tostring(task_data.event_name))
end

function M:showEventInfo(cell_data)
	local rewards = nil
	local task_content = self:findGameObject("task_content")
	local luaBehaviour = task_content:GetComponent("LuaBehaviour")

	self.m_model.m_sel_cell_data = cell_data
	
	rewards = self:showTaskInfo(cell_data, luaBehaviour)
	
	rewards = rewards or {}
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_reward_text", "new_str_0622")

	local reward_node = luaBehaviour:FindGameObject("reward_node")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_reward_text", #rewards == 0)
	GameUtil:createRewards(reward_node.transform, rewards, true, true, nil, 1)
end

function M:showTaskInfo(cell_data, luaBehaviour)
	local rewards = {}
	local task_team_data = self.regional_task_team_cfg[cell_data.task_team_id]

	local content = luaBehaviour:FindGameObject("info_content")
	local contentImmediate = content:GetComponent("ContentImmediate")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_name_text", "new_str_0581")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "task_story_text", task_team_data.task_describe)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "go_event_text", "new_str_0029")

	local done = {}
	if cell_data.done then
		for k,v in ipairs(cell_data.done) do
			table.insert(done, {id = v, finish = true})
		end
	end
	table.insert(done, {id = cell_data.task_id, finish = false})

	local all_cell_size = {}
	for i,v in pairs(done) do
		if v.id ~= cell_data.task_id then
			all_cell_size[i] = Vector2(620, 39)
		else
			all_cell_size[i] = Vector2(620, 118)
		end
	end
	local m_task_loop_scroll_view = nil
	if m_task_loop_scroll_view == nil then
		local loopscroll = luaBehaviour:FindGameObject("list_Scroll_View")
		local params = {
			show_data = done,
			loop_scroll_object = loopscroll,
			all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cellData)
				local task_data = self.regional_task_cfg[cellData.id]

				local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				if LuaBehaviour then
					local str = Language:getTextByKey(task_data.event_mission)
					LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_name", str)
					LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigou", cellData.finish)
					if cellData.id == cell_data.task_id then
						LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "task_info_text", true)
						LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "task_info_text", task_data.event_story)
					else
						LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "task_info_text", false)
					end
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end,
			ui_name = self.m_uiName,
		}
		m_task_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		m_task_loop_scroll_view:reloadData(done)
	end
	m_task_loop_scroll_view:setVerticalNormalizedPosition(0)
	contentImmediate:ForceRefreshSize()

	if #task_team_data.task_id == 2 then
		local lastTask_id = task_team_data.task_id[#task_team_data.task_id]
		local lastTask = self.regional_task_cfg[lastTask_id]
		if lastTask then
			rewards = lastTask.item_reward or {}
		end
	end
	return rewards
end

return M
