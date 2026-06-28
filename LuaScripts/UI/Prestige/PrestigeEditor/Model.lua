---@class PrestigeEditorModel : OODataBase
local M = class("PrestigeEditorModel", LikeOO.OODataBase)

M.tmp_block_data = {}

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.star_sort_type = 1
	self.is_sort_list_open = false
	self.is_rotate_on = false
	self.is_data_saved = true
	self.operated_block_ids = {}
	self.conflict_block_ids = {}
	self.self_time_data = {} --倒计时数据
	self.board_cfg = ConfigManager:getCfgByName("prestige_checkerboard")
	self.affix_cfg = ConfigManager:getCfgByName("prestige_piece_affix")
	self.block_shape_cfg = ConfigManager:getCfgByName("prestige_piece_shape")
	self.upgrade_cfg = ConfigManager:getCfgByName("prestige_checkerboard_upgrade")
	self:refreshData()
end

function M:refreshData()
	self.cur_board_type = PrestigeUtil.cur_board_type
	self.slot_count_per_line = PrestigeUtil.slot_count_per_line
	local tmp_block_data = table.copy(PrestigeUtil:getBlockDataForBoard(self.cur_board_type))
	local tmp_coordinate = table.copy(PrestigeUtil:getCoordinateData(self.cur_board_type))
	self:checkExpiredBlocks(tmp_block_data)
	self.tmp_block_data = tmp_block_data
	self.tmp_coordinate = tmp_coordinate
	self.coordinate_min_index , self.coordinate_max_index = PrestigeUtil:getCoordinateIndexRange()
	self:initBlockToCoordinate()
	PrestigeUtil:recordBoardDataBeforeEdit(self.cur_board_type)
end

function M:checkExpiredBlocks(data)
	self.expired_block_ids = {}
	local new_block_data = data
	local old_block_data = self.tmp_block_data
	for block_id, _ in pairs(old_block_data) do
		if not new_block_data[block_id] then
			table.insert(self.expired_block_ids, block_id)
		end
	end
end

function M:getExpiredBlockIDs()
	return self.expired_block_ids
end

function M:initBlockToCoordinate()
	self.block_to_coordinate = {}  -- [block_id] = {{i,j}, {i,j}, ...}
	for row = self.coordinate_min_index, self.coordinate_max_index do
		for column = self.coordinate_min_index, self.coordinate_max_index do
			local slot_data = self.tmp_coordinate[row][column]
			if slot_data then
				for k,v in pairs(slot_data) do
					local block_id = k
					local coordinates = self.block_to_coordinate[block_id] or {}
					table.insert(coordinates, {row, column})
					self.block_to_coordinate[block_id] = coordinates
				end
			end
		end
	end
end

function M:getAnchorPointOfBlockShape(block_shape)
	return self.block_shape_cfg[block_shape].anchor_point
end

function M:getStarByShape(block_shape)
	return self.block_shape_cfg[block_shape].star
end

function M:getBlockDataForCurrentBoard()
	local block_list = {}
	local need_sort = self.star_sort_type ~= 1
	
	for _,v in pairs(self.tmp_block_data) do
		if need_sort then
			local target_star = self.star_sort_type - 1
			local block_star = self:getStarByShape(v.shape)
			if block_star == target_star then
				table.insert(block_list, v)
			end
		else
			table.insert(block_list, v)
		end
	end
	for _, v in pairs(block_list) do
		v.times = 0
		if v.expire and v.expire > 0  then
			v.times = v.expire - UserDataManager:getServerTime()
		else
			v.times = 0
		end
	end
	return block_list
end

function M:getNonEmptyBoardData()
	local non_empty_board = {}
	for row = 1,self.slot_count_per_line do
		for column, block_ids in pairs(self.tmp_coordinate[row]) do
			local row_str = row < 10 and "0" .. row or tostring(row)
			local column_str = column < 10 and "0" .. column or tostring(column)
			local pos_str = row_str .. column_str
			for block_id,_ in pairs(block_ids) do
				non_empty_board[pos_str] = block_id	
			end
		end
	end
	return non_empty_board
end

function M:getOperatedBlockData()
	local block_data = {}
	for id, _ in pairs(self.operated_block_ids) do
		local data = self.tmp_block_data[id]
		table.insert(block_data, {data.id, data.status, data.anchor})
	end
	return block_data
end

-- 每次操作后，检测冲突情况
function M:checkConflict()
	local locked_slots = PrestigeUtil:getLockedSlots(self.cur_board_type)
	local available_slots = PrestigeUtil:getAvailableSlots(self.cur_board_type)
	self.conflict_block_ids = {}
	for row = self.coordinate_min_index, self.coordinate_max_index do
		for column = self.coordinate_min_index, self.coordinate_max_index do
			local block_ids = self.tmp_coordinate[row][column]
			if block_ids then
				local block_count = 0
				for _,_ in pairs(block_ids) do
					block_count = block_count + 1
				end
				if block_count > 1 then
					for k,_ in pairs(block_ids) do
						self.conflict_block_ids[k] = 1
					end
				elseif self:outsideBoard(row, column) then
					local id = next(block_ids)
					self.conflict_block_ids[id] = 1
				elseif locked_slots[row] and locked_slots[row][column] then
					local id = next(block_ids)
					self.conflict_block_ids[id] = 1
				elseif not available_slots[row] or not available_slots[row][column] then
					local id = next(block_ids)
					self.conflict_block_ids[id] = 1
				end
			end
		end
	end
end

function M:hasBoardConflict()
	return next(self.conflict_block_ids) ~= nil
end

function M:isBlockInConflict(block_id)
	return self.conflict_block_ids[block_id] ~= nil
end

function M:outsideBoard(row, column)
	return row < 1 or row > self.slot_count_per_line or column < 1 or column > self.slot_count_per_line
end

-- 清除棋盘
function M:clearBoard()
	local cleared_blocks = {}
	-- 清除棋盘数据
	for row = self.coordinate_min_index , self.coordinate_max_index do
		for column, block_ids in pairs(self.tmp_coordinate[row]) do
			for id,_ in pairs(block_ids) do
				cleared_blocks[id] = 1
				self.operated_block_ids[id] = 1
				self.block_to_coordinate[id] = nil
				self.is_data_saved = false
			end
		end
		self.tmp_coordinate[row] = {}
	end
	-- 更新棋子数据：id，棋子状态，棋子位置
	for id,_ in pairs(cleared_blocks) do
		local block_data = self.tmp_block_data[id]
		block_data.status = 0
		block_data.anchor = "0000"
		self.tmp_block_data[id] = block_data
	end
end

-- 放置到棋盘
function M:putToBoard(data)
	-- 更新棋子数据：id，棋子状态，棋子位置
	local block_id = data.block_id
	local anchor_row = GlobalTools:toint(data.anchor_row)
	local anchor_column = GlobalTools:toint(data.anchor_column)
	local anchor_row_str = anchor_row < 10 and "0" .. anchor_row or tostring(anchor_row)
	local anchor_column_str = anchor_column < 10 and "0" .. anchor_column or tostring(anchor_column)
	local block = self.tmp_block_data[block_id]
	block.status = block.status ~= 0 and block.status or 1
	block.anchor = anchor_row_str .. anchor_column_str
	-- 更新棋盘数据
	self:removeBlockFromBoard(block_id)
	for _,v in ipairs(data.unit_indexes) do
		local row = v[1]
		local column = v[2]
		local slot_data = self.tmp_coordinate[row][column] or {}
		slot_data[block_id] = 1
		self.tmp_coordinate[row][column] = slot_data
		self.block_to_coordinate[block_id] = data.unit_indexes
	end
	self.operated_block_ids[block_id] = 1
	self.is_data_saved = false
	self:checkConflict()
end

-- 放置回背包
function M:putBlockToBag(data)
	local block_data = data.block_data
	local block_id = block_data.id
	-- 更新棋盘数据
	self:removeBlockFromBoard(block_id)
	-- 更新棋子数据
	block_data.status = 0
	block_data.anchor = "0000"
	self.tmp_block_data[block_id] = block_data
	self.operated_block_ids[block_id] = 1
	self.is_data_saved = false
end

function M:removeBlockFromBoard(block_id)
	if self.block_to_coordinate[block_id] then
		for _,pos in ipairs(self.block_to_coordinate[block_id]) do
			local row = pos[1]
			local column = pos[2]
			local slot_data = self.tmp_coordinate[row][column]
			slot_data[block_id] = nil
			if not next(slot_data) then
				self.tmp_coordinate[row][column] = nil
			end
		end
		self.block_to_coordinate[block_id] = nil
	end
end

function M:isBlockEquipped(block_data)
	return block_data.status ~= 0
end

function M:getBlockToCoordinate()
	return self.block_to_coordinate
end

function M:getEquippedBlockData()
	local blocks_data = {}
	for id, v in pairs(self.block_to_coordinate) do
		local block_data = self:getBlockDataByID(id)
		blocks_data[id] = block_data
	end
	return blocks_data
end

function M:getBlockDataByID(id)
	return self.tmp_block_data[id]
end

function M:rotateBlock(id)
	local block_data = self.tmp_block_data[id]
	block_data.status = (block_data.status + 1) % 5
	block_data.status = block_data.status == 0 and 1 or block_data.status
	self.tmp_block_data[id] = block_data
end

function M:updateBoardAfterRotate(data)
	local block_id = data.block_id
	self:removeBlockFromBoard(block_id)
	for _,v in ipairs(data.unit_indexes) do
		local row = v[1]
		local column = v[2]
		local slot_data = self.tmp_coordinate[row][column] or {}
		slot_data[block_id] = 1
		self.tmp_coordinate[row][column] = slot_data
		self.block_to_coordinate[block_id] = data.unit_indexes
	end
	self.operated_block_ids[block_id] = 1
	self.is_data_saved = false
	self:checkConflict()
end

-- 旋转按钮
function M:switchRotateState()
	local state = self.is_rotate_on
	self.is_rotate_on = not state
end

-- 获取棋盘名称
function M:getBoardTitle()
	return self.board_cfg[self.cur_board_type].checkerboard_name
end

function M:getAttrByAffixID(id)
	return self.affix_cfg[id].attr
end

function M:updateDataTime()
	for k,v in pairs(self.self_time_data) do
		if v.cell_data then
			if v.cell_data.times and v.cell_data.times > 0 then
				v.cell_data.times = v.cell_data.times - 1
			end
		end
	end	
end

return M