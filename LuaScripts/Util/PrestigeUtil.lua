---@class PrestigeUtil
local M = class("PrestigeUtil")

M.cur_board_type = -1
M.block_max_length = 4
M.slot_count_per_line = 11

M.locked_slots = {}
M.hero_on_board = {}
M.block_on_board = {}
M.available_slots = {}
M.all_board_data_before_edit = {}
M.all_new_board = {}
M.is_new_block = false

function M:init()
    self.coordinate_min_index = 1 - (self.block_max_length - 1) 
    self.coordinate_max_index = self.slot_count_per_line + (self.block_max_length - 1)
    self.board_cfg = ConfigManager:getCfgByName("prestige_checkerboard")
    self.upgrade_cfg = ConfigManager:getCfgByName("prestige_checkerboard_upgrade")
    local piece_info = UserDataManager:getPrestigePieces()
    self:updateAllBlockData(piece_info)
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.netDataUpdateEvent})
end

function M:netDataUpdateEvent(event, data)
    local curEvent = data.event
    local need_update_view = false
    
    if curEvent == "board_data" then
        need_update_view = true
        local board_data = UserDataManager:getPrestigeBoard()
        self:updateAllBoardData(board_data)
    elseif curEvent == "piece_data" then
        need_update_view = true
        local piece_info = UserDataManager:getPrestigePieces()
        self:updateAllBlockData(piece_info)
    end

    if need_update_view then
        EventDispatcher:dipatchEvent("prestige_data_update")
    end
end


--------------------------- 棋盘数据 ---------------------------
function M:initBoardData(data)
    if not self.all_board_data then
        self:updateAllBoardData(data)
    end
end

function M:updateAllBoardData(data)
    self.all_board_data = {}
    if not data then return end
    for k, v in pairs(data) do
        local board_id = tonumber(k)
        local board_data = {}
        local coordinate = {}
        local block_dic = {}
        local hero_dic = {}
        board_data.level = v.level
        for row = self.coordinate_min_index, self.coordinate_max_index do
            coordinate[row] = {}
        end
        for pos, block_id in pairs(v.coordinate) do
            local row = tonumber(string.sub(pos, 1, 2))
            local column = tonumber(string.sub(pos, 3, 4))
            local slot = coordinate[row][column] or {}
            coordinate[row][column] = slot
            coordinate[row][column][block_id] = 1
            if not block_dic[block_id] then
                local block_data = self.all_block_data[block_id]
                local hero_id = block_data.hero
                block_dic[block_id] = 1
                hero_dic[hero_id] = 1 
            end
        end
        board_data.coordinate = coordinate
        self.hero_on_board[board_id] = hero_dic
        self.block_on_board[board_id] = block_dic
        self.all_board_data[board_id] = board_data
        self.cur_board_type = self.cur_board_type ~= -1 and self.cur_board_type or board_id
        self:updateBoardSlotData(board_id)
    end
end

-- 获取特定棋盘的解锁状态
function M:isBoardUnlocked(board_type)
    return self.all_board_data[board_type] ~= nil
end

-- 获取特定棋盘的盘面数据
function M:getCoordinateData(board_type)
    if self.all_board_data[board_type] then
        return self.all_board_data[board_type].coordinate
    end
end

-- 根据格子索引值，返回对应的格子数据
function M:getSlotDataByIndex(board_type, index_row, index_column)
    local board_data = self.all_board_data[board_type]
    local row_data = board_data[index_row] or {}
    local slot_data = row_data[index_column]
    return slot_data
end

-- 获取一个棋盘的数据
function M:getBoardData(board_type)
    return self.all_board_data[board_type]
end

-- 获取一个棋盘的等级
function M:getBoardLevel(board_type)
    local board_data = self.all_board_data[board_type]
    return board_data.level
end

function M:getCoordinateIndexRange()
    return self.coordinate_min_index, self.coordinate_max_index
end

function M:recordBoardDataBeforeEdit(board_type)
    self.all_board_data_before_edit[board_type] = self.all_board_data[board_type]
end

function M:getBoardDataBeforeEdit(board_type)
    return self.all_board_data_before_edit[board_type]
end

-- 更新棋盘槽可用状态数据
function M:updateBoardSlotData(board_type)
    local locked_slots = {}
    local available_slots = {}

    local init_slots = self.board_cfg[board_type].checkerboard_point
    for _,v in ipairs(init_slots) do
        local row = v[1]
        local column = v[2]
        available_slots[row] = not available_slots[row] and {} or available_slots[row]
        available_slots[row][column] = 1
    end

    local upgrade_recipe = self.board_cfg[board_type].upgrade_recipe
    local max_board_level = #self.upgrade_cfg[upgrade_recipe]
    local cur_board_level = self:getBoardLevel(board_type)
    for i = 1, max_board_level do
        local upgrade_data = self.upgrade_cfg[upgrade_recipe][i]
        local unlock_points = upgrade_data.unlock
        for _,v in ipairs(unlock_points) do
            local row = v[1]
            local column = v[2]
            available_slots[row] = not available_slots[row] and {} or available_slots[row]
            available_slots[row][column] = 1
            if i > cur_board_level then
                locked_slots[row] = not locked_slots[row] and {} or locked_slots[row]
                locked_slots[row][column] = i
            end
        end
    end

    self.locked_slots[board_type] = locked_slots
    self.available_slots[board_type] = available_slots
end

function M:getAvailableSlots(board_type)
    return self.available_slots[board_type]
end

function M:getLockedSlots(board_type)
    return self.locked_slots[board_type]
end

function M:isBoardComplete(board_type)
    if next(self.locked_slots[board_type]) then
        return false
    else
        local slots = self.available_slots[board_type]
        local coordinate = self.all_board_data[board_type].coordinate
        for row, columns in pairs(slots) do
            for column,_ in pairs(columns) do
                if not coordinate[row] or not coordinate[row][column] then
                    return false
                end
            end
        end
        return true
    end
end

function M:getHeroOnBoard()
    return self.hero_on_board
end


--------------------------- 棋子数据 ---------------------------
function M:updateAllBlockData(data)
    self.all_block_data = {}
    self.all_new_board = {}
    self.is_new_block = false
    if not data or not next(data) then return end
    for id_str, block_data in pairs(data) do
        local block_id = tonumber(id_str)
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(block_data.hero)
        block_data.id = block_id
        block_data.race = hero_cfg.race
        if block_data.new == 1 then
            self.is_new_block = true
            table.insert(self.all_new_board,block_data)
        end
        self.all_block_data[block_id] = block_data
    end
end

-- 获取特定棋盘可用的棋子数据
function M:getBlockDataForBoard(board_type)
    local data = {}
    local races = {}
    for _, race_id in pairs(self.board_cfg[board_type].race_prestige) do
        races[race_id] = 1
    end
    for id, block_data in pairs(self.all_block_data) do
        if races[block_data.race] then
            data[id] = block_data
        end
    end
    return data
end

-- 获取所有棋子数据
function M:getAllBlockData()
    return self.all_block_data
end

-- 是否有新增的棋子
function M:hasNewBlock()
    local piece_info = UserDataManager:getPrestigePieces()
    self:updateAllBlockData(piece_info)
    return self.is_new_block
end

-- 获取新获得的棋子数据
function M:getNewBlockData()
    local piece_info = UserDataManager:getPrestigePieces()
    self:updateAllBlockData(piece_info)
    return self.all_new_board
end


return M
