---@class PrestigeEditorView : OOPopBase
local M = class("PrestigeEditorView", LikeOO.OOPopBase)
local __SLOT_SIDE_LENGTH = 45.82
local __MINI_SLOT_SIDE_LENGTH = 25
local __CLICK_TIME_THRESHOLD = 0.15

M.m_uiName = "Prestige/PrestigeEditor"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.pos_offset = nil
	self.is_mouse_down = false
	self.pressing_time = 0
	self.cell_objs = {}
	self.mouse_down_time = U3DUtil:RealtimeSinceStartup()
	self.m_grid_obj = self:findGameObject("grid")
	self.m_slot_parent_obj = self:findGameObject("slots")
	self.m_drag_layer_transform = self:findRectTransform("drag_layer")
	self.slot_count_per_line = self.m_model.slot_count_per_line
	GameMain.addUpdate("checkMouseEvent", handler(self, self.checkMouseEvent))
	self:setTextByLanKey("save_btn_text", "prestige_text_010")
	self:setTextByLanKey("clear_btn_text", "prestige_text_011")
	self:setTextByLanKey("sort_text1", "prestige_sort_text_007")
	self:setTextByLanKey("fetter_text", "prestige_jiban_text_001")
	self:setTextByLanKey("board_title", self.m_model:getBoardTitle())
	self:initBlocksOnBoard()
	self:updateRotateBtn()
	self:initSlots()
	self:initSortBtn()
	self:refreshUI()
end

function M:refreshUI()
	self:updateBlockScrollList()
end


--------------------------- 鼠标事件 ---------------------------
function M:checkMouseEvent()
	self:checkMouseDown();
	self:checkMouseMove();
	self:checkMouseUp();
end

function M:checkMouseDown()
	if U3DUtil:Input_GetMouseButtonDown(0) then
		self.is_mouse_down = true
		self.pressing_time = 0
		self.mouse_down_time = U3DUtil:RealtimeSinceStartup()
	end
end

function M:checkMouseMove()
	if self.is_mouse_down then
		self.pressing_time = U3DUtil:RealtimeSinceStartup() - self.mouse_down_time
		if not self:isDraggingBlock() then
			return
		end
		if not self.m_model.is_rotate_on and self.pressing_time >= __CLICK_TIME_THRESHOLD then
			local pointer_screen_pos = Vector3(CS.UnityEngine.Input.mousePosition.x, CS.UnityEngine.Input.mousePosition.y, -11.8);
			local pointer_world_point = UIUtil.screenToWorldPoint(pointer_screen_pos)
			local block_previous_pos = self.selected_block_transform.position
			local pointer_world_pos = Vector3(pointer_world_point.x, pointer_world_point.y, block_previous_pos.z)
			self.pos_offset = self.pos_offset ~= nil and self.pos_offset or block_previous_pos - pointer_world_pos
			local block_target_pos = pointer_world_pos + self.pos_offset
			self.selected_block_transform.position = Vector3.Lerp(block_previous_pos, block_target_pos, 0.25);
		end
	end
end

function M:checkMouseUp()
	if U3DUtil:Input_GetMouseButtonUp(0) then
		self.is_mouse_down = false
		if not self:isDraggingBlock() then
			return
		end
		if self.m_model.is_rotate_on then  -- 旋转棋子
			self:updateMsg("rotate_block", self.selected_block.id)
		elseif self.pressing_time >= __CLICK_TIME_THRESHOLD then  -- 移动棋子
			self:putBlock()
		else  -- 点击棋子
			self:emphasizeBlockInfo()
			self:cancelSelectedBlock()
		end
	end
end


--------------------------- 棋盘 ---------------------------
-- 棋盘盘面
function M:initSlots()
	self.slots = {}
	self.m_slot_cls = CustomRequire("UI.Prestige.PrestigeEditorSlot")
	local locked_slots = PrestigeUtil:getLockedSlots(self.m_model.cur_board_type)
	local available_slots = PrestigeUtil:getAvailableSlots(self.m_model.cur_board_type)
	for i = 1, self.slot_count_per_line do
		self.slots[i] = {}
		for j = 1, self.slot_count_per_line do
			local slot = self.m_slot_cls.new(self.m_control, {parent = self.m_slot_parent_obj})
			self.slots[i][j] = slot
			if not available_slots[i] or not available_slots[i][j] then
				slot:setState(PRESTIGE_EDITOR_SLOT_STATE.UNAVAILABLE)
			elseif locked_slots[i] and locked_slots[i][j] then
				slot:setState(PRESTIGE_EDITOR_SLOT_STATE.LOCKED)
			else
				slot:setState(PRESTIGE_EDITOR_SLOT_STATE.UNLOCKED)
			end
		end
	end
end

-- 根据棋子数据，初始化棋盘盘面
function M:initBlocksOnBoard()
	local block_to_coordinates = self.m_model:getBlockToCoordinate()
	for block_id, _ in pairs(block_to_coordinates) do
		local block_data = self.m_model:getBlockDataByID(block_id)
		if not block_data then return end
		local block = self.m_control.block_manager:generateNormalBlock(block_data, self.m_grid_obj)
		local anchor_str = block_data.anchor
		local index_row = tonumber(string.sub(anchor_str, 1, 2))
		local index_column = tonumber(string.sub(anchor_str, 3, 4))
		local pos = self:getBoardLocalPosBySlotIndex(index_row, index_column)
		block.transform.localPosition = pos
		block:rotateByStatus()
	end
end

-- 判断给定的相对位置在棋盘范围内
function M:isLocalPosWithinBoard(local_pos)
	local index_row, index_column = self:getBoardIndex(local_pos)
	local is_within_board = self:isSlotIndexWithinBoard(index_row, index_column)
	return is_within_board
end

-- 根据一个相对棋盘坐标，返回是否在棋盘内
function M:isSlotIndexWithinBoard(index_row, index_column)
	return index_row >= 1 and index_row <= self.slot_count_per_line and index_column >= 1 and index_column <= self.slot_count_per_line
end

-- 根据一个相对棋盘的位置，返回对应的格子索引值
function M:getBoardIndex(local_pos)
	local x = local_pos.x + 252
	local y = local_pos.y - 252
	local index_row = math.ceil(-y / __SLOT_SIDE_LENGTH)
	local index_column = math.ceil(x / __SLOT_SIDE_LENGTH)
	return index_row, index_column
end

-- 根据坐标，获取棋盘相对位置坐标
function M:getBoardLocalPosBySlotIndex(index_row, index_column)
	local offset = (self.slot_count_per_line + 1) / 2
	local local_pos_x = (index_column - offset) * __SLOT_SIDE_LENGTH
	local local_pos_y = (offset - index_row) * __SLOT_SIDE_LENGTH
	local local_pos = Vector3(local_pos_x, local_pos_y, 0)
	return local_pos
end


--------------------------- 棋子列表 ---------------------------
function M:updateBlockScrollList()
	local block_data = self.m_model:getBlockDataForCurrentBoard()
	self.m_model.self_time_data = {}
	if self.m_block_scroll == nil then
		local list_scroll = self:findGameObject("block_scroll")
		local params = {
			one_line_count = 3,
			show_data = block_data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateBlockInfo(index, cell_object, cell_data)
				self.cell_objs[cell_object] = cell_data
			end 
		}
		self.m_block_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_block_scroll:reloadData(block_data, true)
	end
end

function M:updateBlockInfo(cell_index, cell_object, cell_data)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	self.m_model.self_time_data[cell_object] = {luaBehaviour = luaBehaviour,cell_index= cell_index,cell_data = cell_data,cell_object = cell_object}
	-- 冲突状态
	local is_conflict = self.m_model:isBlockInConflict(cell_data.id)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "conflict_block_effect", is_conflict)
	-- 装备状态
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equipped_mask", cell_data.status ~= 0)
	-- 星级
	local star = self.m_model:getStarByShape(cell_data.shape)
	local posX = -32
	for i = 1,5 do
		local starObj = luaBehaviour:FindGameObject("star" .. i)
		if starObj ~= nil then
			starObj:SetActive(i <= star)
			starObj.transform.localPosition = Vector3(posX, 0,0)
			if star < 5 then
				posX = posX + 32
			elseif star == 5 then
				posX = posX + 25
			end
		end
	end
	-- 英雄头像
	local bg_name = "a_ui_currency_ws_jin_small" or cell_data.bg_name
	local avatar_name = "TX_" .. cell_data.hero
	LuaBehaviourUtil.setImg(luaBehaviour, "hero_bg", bg_name, "hero_head_ui")
	LuaBehaviourUtil.setImg(luaBehaviour, "hero_avatar", avatar_name, "hero_head_ui")
	-- 过期时间
	--local times = cell_data.expire and cell_data.expire - UserDataManager:getServerTime() or 0
	local times = cell_data.times
	self:setTextByLanKey("cancel_btn",times)
	if times > 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "time_text", true)
		local time_text = luaBehaviour:FindText("time_text")
		local remain_day, remain_hour, remain_min = GameUtil:getTimeLayoutBySecond(times)
		if remain_day >= 1 then
			time_text.text = string.format("%d天", remain_day)
		elseif remain_hour >= 1 then
			time_text.text = string.format("%d小时", remain_hour)
		else
			time_text.text = string.format("%d分钟", remain_min)
		end
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "time_text", false)
	end
	-- 棋子词缀
	local affixes = {}
	for _,v in pairs(cell_data.affix) do
		for _,j in pairs(v) do
			local attr = self.m_model:getAttrByAffixID(j)
			local name = UserDataManager:getNewAttrsNameByAttrId(attr[1])
			local value = attr[2]
			table.insert(affixes, {name, value})
		end
	end
	for i = 1,3 do
		local affix = affixes[i]
		if affix then
			local name_text = affix[1]
			local value_text = affix[2] < 1 and (affix[2] * 100) .. "%" or tostring(affix[2])
			local affix_text = name_text .. "+" .. value_text
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_text" .. i, true)
			LuaBehaviourUtil.setText(luaBehaviour,"effect_text" .. i, affix_text)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_text" .. i, false)
		end
	end
	-- todo：棋子形状 —— 使用对象池优化
	local mini_grid = luaBehaviour:FindGameObject("mini_grid")
	UIUtil.destroyAllChild(mini_grid.transform)
	local mini_block = self.m_control.block_manager:generateMiniBlock(cell_data, mini_grid)
	local block_transform = mini_block:getTransform()
	local anchor_point = self.m_model:getAnchorPointOfBlockShape(cell_data.shape)
	local pos = self:getPosOnMiniGrid(anchor_point)
	block_transform.localPosition = pos
	-- 拖动回调
	local scrollRectClick = luaBehaviour.gameObject:GetComponent("ScrollRectClick")
	if scrollRectClick then
		local btn = luaBehaviour.gameObject:GetComponent("Button")
		local function createBlock(click_type, index)
			if self.m_model.is_rotate_on or self:isDraggingBlock()then
				return
			end
			if click_type == 3 and cell_data.status == 0  then
				local params = {
					block_data = cell_data,
					grid_obj = self.m_grid_obj
				}
				self:updateMsg("create_block", params)
				audio:SendEvtUI("Play_UI_NormalClick")
			end
		end
		btn.enabled = false
		scrollRectClick.index = cell_index
		scrollRectClick:RegistClickCallBack(createBlock)
	end
end

function M:updateBlockInfoTime()
	--for cell_obj, cell_data in pairs(self.cell_objs) do
	--	local luaBehaviour = cell_obj:GetComponent("LuaBehaviour")
	--	if cell_data.expire ~= 0 then
	--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "time_text", true)
	--		local time_text = luaBehaviour:FindText("time_text")
	--		local left_ts = cell_data.expire - UserDataManager:getServerTime()
	--		local remain_day, remain_hour, remain_min = GameUtil:getTimeLayoutBySecond(left_ts)
	--		if remain_day >= 1 then
	--			time_text.text = string.format("%d天", remain_day)
	--		elseif remain_hour >= 1 then
	--			time_text.text = string.format("%d小时", remain_hour)
	--		else
	--			time_text.text = string.format("%d分钟", remain_min)
	--		end
	--	else
	--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "time_text", false)
	--	end
	--end
	for k,v in pairs(self.m_model.self_time_data) do
		local times = v.cell_data.times
		Logger.logAlways("-------------------------------- current_time_S:"..tostring(times))
		if times > 0 then
			LuaBehaviourUtil.setObjectVisible( v.luaBehaviour, "time_text", true)
			local remain_day, remain_hour, remain_min ,sec= GameUtil:getTimeLayoutBySecond(times)
			Logger.logAlways("-------------------------------- current_time:"..tostring(sec))
			if remain_day >= 1 then
				LuaBehaviourUtil.setText(v.luaBehaviour,"time_text",string.format("%d天", remain_day))
			elseif remain_hour >= 1 then
				LuaBehaviourUtil.setText(v.luaBehaviour,"time_text",string.format("%d小时", remain_hour))
			else
				LuaBehaviourUtil.setText(v.luaBehaviour,"time_text",string.format("%d分钟", remain_min))
			end
		else
			LuaBehaviourUtil.setObjectVisible(v.luaBehaviour, "time_text", false)
		end
	end
end

function M:moveToScrollTop()
	if self.m_block_scroll ~= nil then
		local data = self.m_model:getBlockDataForCurrentBoard()
		if #data > 0 then
			self.m_block_scroll:moveToCellIndex(1)
		end
	end
end

function M:getPosOnMiniGrid(anchor_point)
	return self:getMiniBoardLocalPosBySlotIndex(anchor_point[1], anchor_point[2])
end

-- 根据格子索引值，获取棋盘相对位置坐标
function M:getMiniBoardLocalPosBySlotIndex(index_row, index_column)
	local local_pos_x = (index_column - 2.5) * __MINI_SLOT_SIDE_LENGTH
	local local_pos_y = (2.5 - index_row) * __MINI_SLOT_SIDE_LENGTH
	local local_pos = Vector3(local_pos_x, local_pos_y, 0)
	return local_pos
end

-- 点击棋子后，移动到并缩放棋子 info
function M:emphasizeBlockInfo()
	local block_star = self.m_model:getStarByShape(self.selected_block.shape)
	if self.m_model.star_sort_type == 1 or self.m_model.star_sort_type - 1 == block_star then
		local block_id = self.selected_block.id
		local show_data = self.m_block_scroll.m_show_data
		local cell_index = 1
		for k,v in ipairs(show_data) do
			if v.id == block_id then
				cell_index = k
				break
			end
		end
		self.m_block_scroll:moveToCellIndex(cell_index)
		local cell_obj = self.m_block_scroll.m_cache_cells[cell_index]
		local cell_transform = cell_obj.transform
		local sequence = Tweening.DOTween.Sequence()
		sequence:Append(cell_transform:DOScale(1.05, 0.25))
		sequence:Append(cell_transform:DOScale(1, 0.15))
		sequence:SetAutoKill(true)
	end
end


--------------------------- 棋子 ---------------------------
-- 是否正在操作棋子
function M:isDraggingBlock()
	return self.selected_block ~= nil
end

-- 获取点击生成的新棋子
function M:onBlockCreated(block)
	local pointer_screen_pos = Vector3(CS.UnityEngine.Input.mousePosition.x, CS.UnityEngine.Input.mousePosition.y, -11.8);
	local pointer_world_point = UIUtil.screenToWorldPoint(pointer_screen_pos)
	local pointer_world_pos = Vector3(pointer_world_point.x, pointer_world_point.y, 10100)
	block.m_rt.position = pointer_world_pos
	self:setSelectedBlock(block)
end

-- 设置鼠标选中的棋子
function M:setSelectedBlock(block)
	if self:isDraggingBlock() then
		return
	end
	
	self.selected_block = block
	self.selected_block_transform = self.selected_block:getTransform()
	self.selected_block_transform:SetParent(self.m_drag_layer_transform, false)

	local pointer_screen_pos = Vector3(CS.UnityEngine.Input.mousePosition.x, CS.UnityEngine.Input.mousePosition.y, -11.8);
	local pointer_world_point = UIUtil.screenToWorldPoint(pointer_screen_pos)
	local block_previous_pos = self.selected_block_transform.position
	local pointer_world_pos = Vector3(pointer_world_point.x, pointer_world_point.y, block_previous_pos.z)
	self.pos_offset = self.pos_offset ~= nil and self.pos_offset or block_previous_pos - pointer_world_pos
end

-- 取消选中当前的棋子
function M:cancelSelectedBlock()
	self.selected_block_transform:SetParent(self.m_grid_obj.transform, false)
	self.pos_offset = nil
	self.selected_block = nil
	self.selected_block_transform = nil
end

-- 旋转棋子
function M:rotateBlock()
	self.selected_block:rotateByStatus()

	local unit_indexes = {}
	for k,_ in ipairs(self.selected_block.unit_data) do
		local local_pos = self.selected_block:getUnitPosRelatedToBoard(k)
		local row, column = self:getBoardIndex(local_pos)
		table.insert(unit_indexes, { row, column })
	end
	local params = {
		block_id = self.selected_block.id,
		unit_indexes = unit_indexes
	}
	self:updateMsg("update_board_after_rotate", params)
	
	self:cancelSelectedBlock()
	audio:SendEvtUI("Play_UI_Popup_3")
end

-- 放置棋子
function M:putBlock()
	local is_block_within_board = false
	for k,_ in ipairs(self.selected_block.unit_data) do
		local local_pos = self.selected_block:getUnitPosRelatedToBoard(k)
		local is_unit_within_board = self:isLocalPosWithinBoard(local_pos)
		if is_unit_within_board then
			is_block_within_board = true
			break
		end
	end

	if is_block_within_board then
		self:putBlockToBoard()
	else
		self:putBlockBackToBag()
	end
end

-- 放置棋子至棋盘
function M:putBlockToBoard()
	local anchor_unit_pos = self.selected_block:getUnitPosRelatedToBoard(1)
	local index_row, index_column = self:getBoardIndex(anchor_unit_pos)
	local target_local_pos = self:getBoardLocalPosBySlotIndex(index_row, index_column)
	local put_pos_offset = target_local_pos - anchor_unit_pos
	local block_target_pos = self.selected_block_transform.localPosition + put_pos_offset
	self.selected_block_transform.localPosition = block_target_pos

	local unit_indexes = {}
	for k,_ in ipairs(self.selected_block.unit_data) do
		local local_pos = self.selected_block:getUnitPosRelatedToBoard(k)
		local row, column = self:getBoardIndex(local_pos)
		table.insert(unit_indexes, { row, column })
	end
	local params = {
		block_id = self.selected_block.id,
		anchor_row = index_row,
		anchor_column = index_column,
		unit_indexes = unit_indexes
	}
	self:updateMsg("put_block_to_board", params)
	
	self:cancelSelectedBlock()
	audio:SendEvtUI("UI_Tab_N1")
end

-- 放棋子回背包
function M:putBlockBackToBag()
	self.m_control.block_manager:clearBlock(self.selected_block.id)
	self:updateMsg("put_block_back_to_bag", self.selected_block)
	self:cancelSelectedBlock()
end


--------------------------- 其他 ---------------------------
function M:updateRotateBtn()
	local rotate_btn_key = self.m_model.is_rotate_on and "prestige_text_009" or "prestige_text_008"
	self:setTextByLanKey("rotate_btn_text", rotate_btn_key)
end

function M:initSortBtn()
	self.selected_img_tab = {}
	for i = 1, 6 do
		table.insert(self.selected_img_tab, self:findGameObject("img_select_".. i))
		self:setTextByLanKey("txt_sort_" .. i, "prestige_sort_text_00" .. i)
		local btn_item = self:findGameObject("btn_sort_" .. i)
		UIUtil.setButtonClick(btn_item, function()
			self.m_control:onSortGridList(i)
		end)
	end
end

function M:onRefreshSortNode()
	self:setObjectVisible("sort_list1", false)
	local type = self.m_model.star_sort_type
	if type == 1 then
		self:setTextByLanKey("sort_text1", "prestige_sort_text_007")
	else
		self:setTextByLanKey("sort_text1", "prestige_sort_text_00" .. type)
	end
	for k, v in ipairs(self.selected_img_tab) do
		v:SetActive(k == tonumber(type))
	end
	self:refreshUI()
	self:moveToScrollTop()
end

function M:getGridObj()
	return self.m_grid_obj
end

function M:destroy()
	GameMain.removeUpdate("checkMouseEvent");
	M.super.destroy(self)
end

return M