---@class PrestigeEditorControl : OOControlBase
local M = class("PrestigeEditorControl", LikeOO.OOControlBase)

function M:onCreate()
    self:initBlockManager()
end

function M:onEnter()
    self.expire_block_timer = self:setTimer(1, handler(self, self.updateExpireTime))
    EventDispatcher:registerEvent("prestige_data_update", {self, self.refreshDataAndView })
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_view:isDraggingBlock() then
            return
        end
        self:exitEditor()
    elseif msg == "clear_btn" then
        if self.m_view:isDraggingBlock() then
            return
        end
        self.m_model:clearBoard()
        self.block_manager:clearAllBlocks()
        self.m_model:checkConflict()
        self.m_view:refreshUI()
    elseif msg == "fetter_btn" then
        if self.m_view:isDraggingBlock() then
            return
        end
        self:openView("Prestige.PrestigeHeroFetter", {index = self.m_model.cur_board_type})
    elseif msg == "rotate_btn" then
        if self.m_view:isDraggingBlock() then
            return
        end
        self.m_model:switchRotateState()
        self.m_view:updateRotateBtn()
    elseif msg == "save_btn" then
        if self.m_view:isDraggingBlock() then
            return
        end
        if self.m_model:hasBoardConflict() then
            GameUtil:lookInfoTips(self, {msg = "prestige_text_007", delay_close = 2})
        else
            self:savePrestigeData()
        end
    elseif msg == "help_btn" then
        if self.m_view:isDraggingBlock() then
            return
        end
        self:showHelpPop()
    elseif string.find(msg,'press_prestige_block_') then
        if self.m_view:isDraggingBlock() then
            return
        end
        local sp = string.split(msg, '_')
        local block_id = tonumber(sp[4])
        local block = self.block_manager:getBlockByID(block_id)
        self.m_view:setSelectedBlock(block)
    elseif msg == "put_block_to_board" then
        self.m_model:putToBoard(data)
        self.m_view:refreshUI()
    elseif msg == "put_block_back_to_bag" then
        local block = data
        if self.m_model:isBlockEquipped(block) then
            self.m_model:putBlockToBag(block)
            self.m_model:checkConflict()
            self.m_view:refreshUI()
        end
    elseif msg == "rotate_block" then
        self.m_model:rotateBlock(data)
        self.m_view:rotateBlock()
    elseif msg == "update_board_after_rotate" then
        self.m_model:updateBoardAfterRotate(data)
        self.m_model:checkConflict()
        self.m_view:refreshUI()
    elseif msg == "create_block" then
        local block_data = data.block_data
        local grid_obj = data.grid_obj
        local block = self.block_manager:generateNormalBlock(block_data, grid_obj)
        self.m_view:onBlockCreated(block)
    elseif msg == "sort_btn1" then
        if self.m_view:isDraggingBlock() then
            return
        end
        self.m_model.is_sort_list_open = not self.m_model.is_sort_list_open
        self.m_view:setObjectVisible("sort_list1", self.m_model.is_sort_list_open)
    end
end

-- 筛选按钮
function M:onSortGridList(index)
    self.m_model.star_sort_type = index
    self.m_model.is_sort_list_open = false
    self.m_view:onRefreshSortNode()
end

-- 刷新数据与显示
function M:refreshDataAndView()
    self.m_model:refreshData()
    self.m_view:refreshUI()
    local expired_block_ids = self.m_model:getExpiredBlockIDs()
    self.block_manager:clearExpiredBlocks(expired_block_ids)
    local blocks_data = self.m_model:getEquippedBlockData()
    self.block_manager:resetBlockData(blocks_data)
end

-- 刷新棋子到期时间
function M:updateExpireTime()
    self.m_model:updateDataTime()
    self.m_view:updateBlockInfoTime()
end

-- 帮助弹窗
function M:showHelpPop()
    local params = {}
    params.title = "prestige_text_006"
    params.content = "tid#prestige_des"
    self:openView("Pops.CommonHelpPop", params)
end

-- 棋子生成器
function M:initBlockManager()
    self.block_manager = require("UI.Prestige.PrestigeBlockManager").new()
    self.block_manager:init()
    self.block_manager:setData(self)
end

-- 保存游戏数据
function M:savePrestigeData()
    local board_type = self.m_model.cur_board_type
    local block_data = self.m_model:getOperatedBlockData()
    local board_data = self.m_model:getNonEmptyBoardData()
    if next(block_data) then
        local params = {
            c_id = board_type,
            pieces = block_data,
            coordinate = board_data
        }
        local function callback(response)
            self.m_model.is_data_saved = true
            PrestigeUtil:updateAllBoardData(response.checkerboard_info)
            PrestigeUtil:updateAllBlockData(response.piece_info)
            GameUtil:lookInfoTips(self, {msg = "prestige_text_012", delay_close = 2})
        end
        self.m_model:getNetData("prestige_fetter", params, callback)
    else
        GameUtil:lookInfoTips(self, {msg = "prestige_text_012", delay_close = 2})
    end
end

-- 退出编辑页
function M:exitEditor()
    if self.m_model.is_data_saved then
        local params = {
            is_from_editor = true,
            is_just_complete = self.m_model.is_just_complete,
        }
        self:openView("Prestige.PrestigeMain", params)
    else
        local params = {
            on_ok_call = function()
                local params = {
                    is_from_editor = true,
                    is_just_complete = self.m_model.is_just_complete,
                }
                self:openView("Prestige.PrestigeMain", params)
            end,
            tow_close_btn = true,
            text = Language:getTextByKey("prestige_text_013")
        }
        self:openView("Pops.CommonPop", params)
    end
end

function M:destroy()
    self:removeTimer(self.expire_block_timer)
    EventDispatcher:unRegisterEvent("prestige_data_update", {self, self.refreshDataAndView })
    M.super.destroy(self)
end

return M
