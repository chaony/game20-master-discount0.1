---@class PrestigeBagControl : OOControlBase
local M = class("PrestigeBagControl", LikeOO.OOControlBase)

function M:onCreate()
    self:initBlockManager()

    self.is_all_selected = false
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "select_btn" then
        self.is_all_selected = not self.is_all_selected 
        self:onSelectAllGrid()
    elseif msg == "cancel_btn" then
        self:closeView()
    elseif msg == "decompose_btn" then
        self:onClickResolveBtn()
    elseif msg == "sort_btn1" then
        self.m_view:setObjectVisible("sort_list1", true)
    end
end

function M:onSelectAllGrid()
    self.m_view:setObjectVisible("selected_img", self.is_all_selected)
    if self.is_all_selected then
        self.m_model:setAllSelectedGrid()
    else
        self.m_model:clearAllSelectedGrid()
    end
    self.m_view:refreshView()
end

function M:onSortGridList(index)
    self.m_model:clearAllSelectedGrid()
    
    self.is_all_selected = false
    self.m_view:setObjectVisible("selected_img", self.is_all_selected)
    
    self.m_model.view_sort_type = index
    audio:SendEvtUI("Play_UI_Popup_3")
    self.m_view:onRefreshSortNode()
end

function M:initBlockManager()
    self.block_manager = require("UI.Prestige.PrestigeBlockManager").new()
    self.block_manager:init()
    self.block_manager:setData(self)
end

function M:onClickResolveBtn()
    if #self.m_model.selected_gridId_tab <= 0 then
        return
    end
    
    local params = {
        on_ok_call = function(msg)
            self:reqResolveGrid()
        end,
        on_cancel_call = function(msg)
        end,
        tow_close_btn = true,
        text = Language:getTextByKey("prestige_bag_text_006")
    }
    static_rootControl:openView("Pops.CommonPop", params)
end

-- 分解棋子
function M:reqResolveGrid()
    --local idStr = ""
    --for i, v in pairs(self.m_model.selected_gridId_tab) do
    --    idStr = idStr .. tostring(v) .. "//"
    --end
    --Logger.log("========================== ".. idStr)
    --
    local params = {
        pids = self.m_model.selected_gridId_tab
    }
    local function callback(response)
        RewardUtil:rewardTipsByData(response.reward)
    end
    self.m_model:getNetData("prestige_resolve", params, callback)
end

function M:onSelectedSingleGrid(id)
    local isHav = false
    for _, v in pairs(self.m_model.selected_gridId_tab) do
        if v == id then
            isHav = true
            break
        end
    end
    if isHav then
        local removeKey = -1
        for k, v in pairs(self.m_model.selected_gridId_tab) do
            if v == id then
                removeKey = k
            end
        end
        if removeKey > 0 then
            table.remove(self.m_model.selected_gridId_tab, removeKey)    
        end
    else
        table.insert(self.m_model.selected_gridId_tab, id)
    end
end

function M:dataUpdateEvent(event, msg)
    if msg.event == "piece_data" then
        local piece_info = UserDataManager:getPrestigePieces()
        PrestigeUtil:updateAllBlockData(piece_info)
        self.m_model:updateData()
        self.is_all_selected = false
        self.m_view:setObjectVisible("selected_img", false)
        self.m_view:refreshView()
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

function M:updateTime()
    self.m_model:UpdateDataTime()
    self.m_view:UpdateDataTimeView()
end

return M
