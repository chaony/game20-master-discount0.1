local M = class("WorldMapLegendView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapLegend"
M.m_size_type = 2

function M:onEnter()
	self.map_table = ConfigManager:getCfgByName("regional_map")
	self.map_area_table = ConfigManager:getCfgByName("map_area")
	self.regional_task_cfg = ConfigManager:getCfgByName("regional_task")
	self.book_node = self:findRectTransform("book_node")
	self:setTextByLanKey("main_title_text", "worldMap_str_001")
	self:setTextByLanKey("exit_tip_text", "new_str_0905")
	self:setTextByLanKey("journal_text", "worldMap_str_003")
	self:setTextByLanKey("title_text", "worldMap_str_013")
	self:setTextByLanKey("left_bg_text", "worldMap_str_012")

	self:refreshUI()
end

function M:refreshUI()
	self:setTextByLanKey("left_bg_text", self.map_area_table[self.m_model.cur_area_id].sections_name)
	self:setObjectVisible("left_arrow_btn", self.m_model.previous_area_id ~= nil)
	self:setObjectVisible("right_arrow_btn", self.m_model.next_area_id ~= nil)
	self:updateEventLoopScroll()
end

function M:updateEventLoopScroll()
	self.mapData = self.m_model.m_allMap
	local all_cell_size = {}
	for i,v in ipairs(self.mapData or {}) do
		if self.m_model.m_select_index == i then
			all_cell_size[i] = Vector2(486, 492)
		else
			all_cell_size[i] = Vector2(94, 492)
		end
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = self.mapData,
			loop_scroll_object = loopscroll,
			all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:clickCell(index, cell_object, cell_data, click_object, click_name)
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(self.mapData,true, all_cell_size)
	end
	if self.m_model.m_select_index ~= nil then
		self.m_loop_scroll_view:moveToCellIndex(self.m_model.m_select_index)
	--else
	--	local cur_map = SceneManager.curScene.cur_map
	--	if cur_map ~= nil and cur_map.map_id ~= nil then
	--		local index = 0
	--		for i = 1, #self.mapData do
	--			if self.mapData[i].id == cur_map.map_id then
	--				index = i
	--				break
	--			end
	--		end
	--		if index ~= 0 then
	--			self.m_loop_scroll_view:moveToCellIndex(index)
	--		end
	--	end
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local rect = cell_object:GetComponent("RectTransform")
	if self.m_model.m_select_index == index then
		rect.sizeDelta = Vector2(486, rect.rect.height)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_panel", true)

		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_left_rope_long", index % 2 == 1 )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_left_rope_short", index % 2 == 0 )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_right_rope_long", index % 2 == 1 )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_right_rope_short", index % 2 == 0 )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_mid_rope", index % 2 == 0 )

		if index == #self.mapData then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_right_rope_long", false )
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_right_rope_short", false )
		end

		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "reward_text", "worldMap_str_011")
		local rewards = self.m_model:getTaskReward(cell_data.id)
		local task_count, max_task_count = self.m_model:getMapCpd(cell_data.id)
		self:updateRewardLoopScroll(rewards, luaBehaviour, task_count >= max_task_count)

		
		local task_data = self.m_model:getTaskData(cell_data.id)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "new_task", #task_data == 0 )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "list_scroll", #task_data ~= 0 )
		if #task_data == 0 then
			local new_task = luaBehaviour:FindGameObject("new_task")
			local fitter = new_task:GetComponent("ContentImmediate")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "new_task_text", self.m_model:getTaskDescribe(cell_data.id))
			--触发刷新自适应大小
			fitter:ForceRefreshSize()
			luaBehaviour:FindButton("new_task_go_btn", function()
				self:updateMsg("go_btn", {map_id = cell_data.id})
			end)
		else
			self:updateTaskLoopScroll(luaBehaviour:FindGameObject("list_scroll"), task_data)
		end 
	else
		rect.sizeDelta = Vector2(94, rect.rect.height)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_panel", false)
	end
	
	local open_flag, pre_task_end, tips_str = SceneManager.curScene:checkMapOpen(cell_data.id)
	local open = open_flag == true and pre_task_end == true
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "map_text", cell_data.name)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_mask", open == false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "treasure_btn", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cpd_img", false)
	if open then
		if cell_data.task_count >= cell_data.total_task_count then
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "treasure_btn", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "done", true)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cpd_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "task_red_point_img", false)
		else
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "treasure_btn", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "done", false)
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cpd_img", true)
			
			local enter_map_list = UserDataManager:getTempData("enter_map_list") or {}
			local show_redPoint = pre_task_end and table.indexof(enter_map_list, cell_data.id) == false
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "task_red_point_img", show_redPoint)
			--LuaBehaviourUtil.setText(luaBehaviour, "cpd_text", cell_data.task_count.."/"..cell_data.total_task_count)
		end
	else
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "treasure_btn", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "done", false)
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cpd_img", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "task_red_point_img", false)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "worldMap_str_004")
	end

	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "left_rope_long", index % 2 == 0 )
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "left_rope_short", index % 2 == 1 )
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_rope_long", index % 2 == 1 )
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_rope_short", index % 2 == 0 )

	if index == 1 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "left_rope_long", false )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "left_rope_short", false )
	elseif index == #self.mapData then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_rope_long", false )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_rope_short", false )
	end
end

function M:clickCell(index, cell_object, cell_data, click_object, click_name)
	if click_name == "map_bg_img" then
		local open_flag, pre_task_end, tips_str = SceneManager.curScene:checkMapOpen(cell_data.id)
		if open_flag == true then
			if pre_task_end == true then
				--if cell_data.task_count == 0 and self.m_model.m_map_task[cell_data.id] == nil then
				--if self.m_model.m_map_task[cell_data.id] == nil then
				--	self.m_control:closeView()
				--	self.m_control:onClick_goBtn(cell_data.id)
				--else
					if self.m_model.m_select_index == index then
						self:updateMsg("select_cell")
					else
						self:updateMsg("select_cell", index)
					end
				--end
			else
				GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
			end
		else
			GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
		end
	elseif click_name == "treasure_btn" then
		local rewards = self.m_model:getTaskReward(cell_data.id)
		if #rewards > 0 then
			self.m_control:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = click_object.transform, show_check_mark = nil, scale = 0.7, offset_y = -30})
		end
	end
end



function M:updateTaskLoopScroll(list_scroll, data)
	if IsNull(list_scroll) then
		return
	end
	data = data or {}

	if self.m_task_scroll_view then
		self.m_task_scroll_view = nil
	end

	local all_cell_size = {}
	for i,v in ipairs(data or {}) do
		local task_data = self.regional_task_cfg[v.id]
		local len = string.len(task_data.event_story)/48
		all_cell_size[i] = Vector2(392, 85 + Mathf.Ceil(len) * 25)
	end
	
	local params = {
		show_data = data,
		loop_scroll_object = list_scroll,
		all_cell_size = all_cell_size,
		update_cell = function(index, cell_object, cell_data)
			self:updateTaskCell(index, cell_object, cell_data)
		end,
		click_func = function(index, cell_object, cell_data, click_object, click_name)
			self:updateMsg(click_name, cell_data)
		end,
		ui_name = self.m_uiName,
	}
	self.m_task_scroll_view = LoopScrollViewUtil.new(params)
	self.m_task_scroll_view:moveToCellIndex(#all_cell_size)
end

function M:updateTaskCell(index, cell_object, cell_data)
	local task_data = self.regional_task_cfg[cell_data.id]
	if task_data then
		local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
		if LuaBehaviour then
			--local str = Language:getTextByKey(task_data.event_mission)
			--LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_name", str)
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "go_btn", cell_data.finish == false)
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "gouxuan_bg_img", cell_data.finish)

			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "task_des_text", task_data.event_story)
			local contentImmediate = cell_object:GetComponent("ContentImmediate")
			contentImmediate:ForceRefreshSize()
		end
	end
end

function M:refreshBook(isLeft)
	local dir = 1
	if isLeft == true then
		dir = -1
	end
	self.book_node:DOLocalMoveX(-self.m_view_width * dir, 0.15):OnComplete(
		function()
			local pos = self.book_node.localPosition
			pos.x = self.m_view_width * dir
			self.book_node.localPosition = pos
			self:refreshUI()
			self.book_node:DOLocalMoveX(0, 0.15)
		end	)
end

function M:updateRewardLoopScroll(reward, reward_luaBehaviour, isDone)
	local loopscroll = reward_luaBehaviour:FindGameObject("reward_loopscroll")
	local params = {
		show_data = reward,
		loop_scroll_object = loopscroll,
		update_cell = function(index, cell_object, cell_data)
			local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
			local itemNode = luaBehaviour:FindGameObject("ItemNode")
			local ui_element = GameUtil:updateItemElement(itemNode, cell_data, true, true, nil, 1)
			if isDone == true then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_text", true)
				UIUtil.setOpacity(itemNode, 0.5)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_text", false)
				UIUtil.setOpacity(itemNode, 1)
			end
		end,
		click_func = function(index, cell_object, cell_data, click_object, click_name)
		end,
		ui_name = self.m_uiName,
	}
	self.m_reward_loop_scroll_view = LoopScrollViewUtil.new(params)

end

function M:destroy()
	M.super.destroy(self)
end

return M