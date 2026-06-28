---@class HalfAnniversaryGroupingView: OOPopBase
---@field m_model HalfAnniversaryGroupingModel
local M = class("HalfAnniversaryGroupingView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryGrouping"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local TGL_NODE = {
    { btn_key = "tgl_btn1", lua_name = "UI.HalfAnniversary.HalfAnniversaryGrouping.HalfAnniversaryGroupingHallNode", btn_text = "tgl_name_text1", text_key = "gift_group_text_0001", select_img = "select_bg1" }, -- 拼团大厅
    { btn_key = "tgl_btn2", lua_name = "UI.HalfAnniversary.HalfAnniversaryGrouping.HalfAnniversaryGroupingMySelfNode", btn_text = "tgl_name_text2", text_key = "gift_group_text_0002", select_img = "select_bg2" }, -- 我的拼团
}

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.dayRefresh })
    self:bindUI()
    self:refreshSlider()
    self:initBottom()
end

function M:bindUI()
    self:setTextByLanKey("close_title_text", "half_year_text_0001")
    self:setTextByLanKey("gain_text", "gift_group_text_0031")
    self.m_content_panel = self:findRectTransform("parent_obj")
    self.m_slider = self:findSlider("Slider")
    self.m_ticket_node = self:findRectTransform("ticket_parent")
    self.m_stageData = self.m_model:getStageData()
    self.m_slider_node = { 0.1, 0.3, 1 }
    local index = self.m_model:getSelIndex()
    for k, v in pairs(TGL_NODE) do
        self:setTextByLanKey(v.btn_text, v.text_key)
        self:setObjectVisible(v.select_img, false)
        if index == k then
            if index == 1 then
                self.m_control:switchGroupHallTab()
            elseif index == 2 then
                self.m_control:switchMyGroupTab()
            end
        end
    end
end

function M:refreshSlider()
    local totalValue = self.m_model:getTotalTimes()
    local curValue = totalValue
    local gainValue = self.m_model:getRtnValue()
    local max_index = 0
    local slider_value = 0.0
    for index, v in ipairs(self.m_stageData) do
        if curValue >= v.phase then
            slider_value = self.m_slider_node[index]
            max_index = index
        else
            break
        end
    end
    if max_index == 0 then
        slider_value = (curValue / self.m_stageData[1].phase) * self.m_slider_node[1]
    elseif max_index >= 3 then
        slider_value = 1.0
    else
        local stage_num = self.m_stageData[max_index + 1].phase - self.m_stageData[max_index].phase
        local left_value = curValue - self.m_stageData[max_index].phase
        slider_value = slider_value + ( left_value / stage_num) * (self.m_slider_node[max_index + 1] - self.m_slider_node[max_index])
    end
    self.m_slider.value = slider_value > 1 and 1 or slider_value
    self:setTextByLanKey("total_text", "gift_group_text_0004", GameUtil:formatValueToString(totalValue))
    local ticket_data = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.VOUCHER, 137, gainValue })
    GameUtil:createItemElementByData(ticket_data, true, true, function() audio:SendEvtUI("Play_UI_Tab")  end, self.m_ticket_node)
end

function M:initBottom()
    if #self.m_stageData == 3 then
        for k, v in pairs(self.m_stageData) do
            local num = math.floor(v.rtn * 100) 
            self:setText("percentage_text" .. k, num .. "%")
            self:setText("num_text" .. k, v.phase)
        end
    end
end

function M:refreshRecvBtn()
    local isCanRecv = false
    self:setObjectVisible("un_recv_img", isCanRecv)
    self.m_recv_btn.enable = isCanRecv
end

function M:switchTabNode(index)
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    for k, v in pairs(TGL_NODE) do
        if k == index then
            self:setObjectVisible(v.select_img, true)
            local tab_cls = CustomRequire(v.lua_name)
            self.m_cur_tab_node = tab_cls.new(self.m_control, { parent = self.m_content_panel })
        else
            self:setObjectVisible(v.select_img, false)
        end
    end
end

function M:showSortPanel()
    if self.m_model:getSelIndex() == 1 and self.m_cur_tab_node then
        self.m_cur_tab_node:showSortPanel()
    end
end

function M:refreshGroupList()
    if self.m_model:getSelIndex() == 1 and self.m_cur_tab_node then
        self.m_cur_tab_node:refreshGroupList()
    end
    self:refreshSlider()
end

function M:refreshSelfList()
    if self.m_model:getSelIndex() == 2 and self.m_cur_tab_node then
        self.m_cur_tab_node:refreshMySelfLoopScroll()
        self.m_cur_tab_node:refreshCellTimer()
    end
    self:refreshSlider()
end

function M:refreshCellTimer()
    if self.m_model:getSelIndex() == 2 and self.m_cur_tab_node then
        self.m_cur_tab_node:refreshCellTimer()
    end
end

function M:dayRefresh()
    if self.m_model:getSelIndex() == 2 and self.m_cur_tab_node then
        self.m_model:updateSelfGroupList({})
        self.m_cur_tab_node:refreshMySelfLoopScroll()
        self.m_cur_tab_node:refreshCellTimer()
    end
    self:updateMsg("day_refresh")
end

function M:getSearchId()
    if self.m_model:getSelIndex() == 1 and self.m_cur_tab_node then
        return self.m_cur_tab_node:getSearchId()
    end
end

function M:resetSearchInfo()
    if self.m_model:getSelIndex() == 1 and self.m_cur_tab_node then
        return self.m_cur_tab_node:resetSearchInfo()
    end
end

function M:destroy()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.dayRefresh})
    M.super.destroy(self)
end

return M