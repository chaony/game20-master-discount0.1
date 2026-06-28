---@class HalfAnniversaryGroupingControl: OOControlBase
---@field m_model HalfAnniversaryGroupingModel
---@field m_view HalfAnniversaryGroupingView
local M = class("HalfAnniversaryGroupingControl", LikeOO.OOControlBase)
local RANDOM_LIST_MAX = 20  --随机列表最大数量
local POLLING_TIME = 60

function M:onEnter()
    self.m_timer_id = self:setTimer(POLLING_TIME, handler(self, self.updateTime))
    self.m_myselfNode_timer_id = self:setTimer(1, handler(self, self.myselfNodeUpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("refresh_entrances", nil, "HalfAnniversary.HalfAnniversaryMain")
        self:closeView()
    elseif msg == "tgl_btn1" then
        audio:SendEvtUI("UI_Tab_N6")
        if self.m_model:getSelIndex() == 1 then
            return
        end
        self:switchGroupHallTab()
    elseif msg == "tgl_btn2" then
        audio:SendEvtUI("UI_Tab_N6")
        if self.m_model:getSelIndex() == 2 then
            return
        end
        self:switchMyGroupTab()
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("half_year_text_0001"), content = Language:getTextByKey("tid#pubicgift_01") })
    elseif msg == "btn_sort" and not self.m_model:getSearchState() then
        --排序面板
        audio:SendEvtUI("UI_NormalClick1")
        self.m_model:setSearchState(true)
        self.m_view:showSortPanel()
    elseif msg == "btn_sort_close" then
        --排序面板
        if self.m_model:getSelIndex() == 1 and self.m_model:getSearchState() then
            self.m_model:setSearchState(false)
            self.m_view:showSortPanel()
        end
    elseif msg == "btn_sort_1" then
        audio:SendEvtUI("UI_NormalClick1")
        if self.m_model:getSelIndex() == 1 and self.m_model:getSearchState() then
            self.m_model:sortGroupList(1)
            self.m_view:refreshGroupList()
            self.m_model:setSearchState(false)
            self.m_view:showSortPanel()
        end
    elseif msg == "btn_sort_2" then
        audio:SendEvtUI("UI_NormalClick1")
        if self.m_model:getSelIndex() == 1 and self.m_model:getSearchState() then
            self.m_model:sortGroupList(2)
            self.m_view:refreshGroupList()
            self.m_model:setSearchState(false)
            self.m_view:showSortPanel()
        end
    elseif msg == "btn_sort_3" then
        audio:SendEvtUI("UI_NormalClick1")
        if self.m_model:getSelIndex() == 1 and self.m_model:getSearchState() then
            self.m_model:sortGroupList(3)
            self.m_view:refreshGroupList()
            self.m_model:setSearchState(false)
            self.m_view:showSortPanel()
        end
    elseif msg == "search_btn" then
        audio:SendEvtUI("UI_NormalClick1")
        --搜索
        if self.m_model:getSelIndex() ~= 1 then
            return
        end
        local id = tonumber(self.m_view:getSearchId())
        if id == nil or id == "" then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gift_group_text_0003"), delay_close = 2 })
            return
        end
        self:refreshGroupList({ id }, true)
        self.m_view:resetSearchInfo()
    elseif msg == "refresh_btn" then
        audio:SendEvtUI("Play_UI_Refresh")
        --刷新
        if self.m_model:getSelIndex() ~= 1 then
            return
        end
        self:refreshNewGroupList()
    elseif msg == "exit_group" then
        --退出
        audio:SendEvtUI("UI_Back")
        if self.m_model:getSelIndex() ~= 2 then
            return
        end
        self:exitGroup(data)
    elseif msg == "join_btn" then
        --加入
        audio:SendEvtUI("UI_Tab_N1")
        if self.m_model:getSelIndex() ~= 1 then
            return
        end
        self:joinGroup(data)
    elseif msg == "invite_group" then
        --邀请
        audio:SendEvtUI("Play_UI_Popup_3")
        if self.m_model:getSelIndex() ~= 2 then
            return
        end
        self:inviteGroup(data)
    elseif msg == "buy" then
        audio:SendEvtUI("UI_Guild_Blessing")
        --购买
        if self.m_model:getSelIndex() ~= 2 then
            return
        end
        self:tryBuyGift(data)
    elseif msg == "group_btn" then
        --组队界面
        audio:SendEvtUI("UI_Tab_N5")
        if self.m_model:getSelIndex() ~= 2 then
            return
        end
        local curDayGiftList = self.m_model:getCurDayGiftData() or {}
        local params = { curDayGiftList = curDayGiftList, version = self.m_model:getVersion() }
        self:openView("HalfAnniversary.HalfAnniversaryGroupingPop", params)
    elseif msg == "day_refresh" then
        --每日刷新
        self:setOnceTimer(1, self:dayRefresh())
    elseif msg == "create_group" then
        --发起拼团
        audio:SendEvtUI("UI_Tab_N5")
        if self.m_model:getSelIndex() ~= 2 then
            return
        end
        self.m_model:updateSelfGroupList(data.groups)
        self.m_model:setTotalTimes(data.total_pay_times)
        self.m_model:setTotalPayValue(data.self_total_payment)
        self.m_view:refreshSelfList()
    end
end

function M:inviteGroup(data)
    local params = {create_time = data.create_time, group_id = data.group_id, version = self.m_model:getVersion()}
    self:openView("HalfAnniversary.HalfAnniversaryGroupingSharePop", params)
end

function M:joinGroup(group_id)
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        self.m_model:updateGroupList(response.groups)
        self.m_model:setTotalTimes(response.total_pay_times)
        self.m_model:setTotalPayValue(response.self_total_payment)
        if self.m_model:getSelIndex() == 1 then
            self.m_view:refreshGroupList()
        end
    end
    local params = { vsn = self.m_model:getVersion(), group_id = group_id }
    self.m_model:getNetData("gift_join_group", params, callback)
end

function M: tryBuyGift(data)
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        if response.can_pay == 1 then
            self:buyItemByChargeId(data.charge_id)
        else
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gift_group_text_0026"), delay_close = 2 })
            self:refreshMySelfList()
        end
    end
    local params = { vsn = self.m_model:getVersion(), group_id = data.group_id }
    self.m_model:getNetData("gift_check_can_buy", params, callback)

end

function M:dayRefresh()
    if static_rootControl:hasChild("HalfAnniversary.HalfAnniversaryGroupingPop") then
        static_rootControl:closeView("HalfAnniversary.HalfAnniversaryGroupingPop", nil, false)
    end
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        self.m_model:refreshMainData(response)
        if self.m_model:getSelIndex() == 1 then
            self:randomGroupList()
        elseif self.m_model:getSelIndex() == 2 then
            self:refreshMySelfList()
        end
    end
    self.m_model:getNetData("gift_grouping_index",nil, callback)


end

function M:exitGroup(group_id)
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        self.m_model:updateSelfGroupList(response.groups)
        self.m_model:setTotalTimes(response.total_pay_times)
        self.m_model:setTotalPayValue(response.self_total_payment)
        if self.m_model:getSelIndex() == 2 then
            self.m_view:refreshSelfList()
        end
    end
    local params = { vsn = self.m_model:getVersion(), group_id = group_id }
    self.m_model:getNetData("gift_exit_group", params, callback)
end

function M:switchGroupHallTab()
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        self.m_model:updateGroupList(response.groups)
        self.m_model:setTotalTimes(response.total_pay_times)
        self.m_model:setTotalPayValue(response.self_total_payment)
        self.m_model:setSelIndex(1)
        self.m_model:setSearchState(false)
        self.m_view:switchTabNode(1)

    end
    local params = { vsn = self.m_model:getVersion(), num = RANDOM_LIST_MAX }
    self.m_model:getNetData("gift_random_group_list", params, callback)
end

function M:refreshNewGroupList()
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        if #response.groups == 0 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gift_group_text_0027"), delay_close = 2 })
        end
        self.m_model:updateGroupList(response.groups)
        self.m_model:setTotalTimes(response.total_pay_times)
        self.m_model:setTotalPayValue(response.self_total_payment)
        if self.m_model:getSelIndex() == 1 then
            self.m_view:refreshGroupList()
        end
    end
    local params = { vsn = self.m_model:getVersion(), num = RANDOM_LIST_MAX }
    self.m_model:getNetData("gift_random_group_list", params, callback)
end

function M:randomGroupList()
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        self.m_model:updateGroupList(response.groups)
        self.m_model:setTotalTimes(response.total_pay_times)
        self.m_model:setTotalPayValue(response.self_total_payment)
        if self.m_model:getSelIndex() == 1 then
            self.m_view:refreshGroupList()
        end
    end
    local params = { vsn = self.m_model:getVersion(), num = RANDOM_LIST_MAX }
    self.m_model:getNetData("gift_random_group_list", params, callback)
end

function M:switchMyGroupTab()
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        self.m_model:updateSelfGroupList(response.groups)
        self.m_model:setTotalTimes(response.total_pay_times)
        self.m_model:setTotalPayValue(response.self_total_payment)
        self.m_model:setSelIndex(2)
        self.m_view:switchTabNode(2)
    end
    local params = { vsn = self.m_model:getVersion() }
    self.m_model:getNetData("gift_my_group_list", params, callback)
end

function M:refreshGroupList(group_ids, isSearch)
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        if isSearch and #response.groups == 0 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gift_group_text_0027"), delay_close = 2 })
        end
        self.m_model:updateGroupList(response.groups)
        self.m_model:setTotalTimes(response.total_pay_times)
        self.m_model:setTotalPayValue(response.self_total_payment)
        if self.m_model:getSelIndex() == 1 then
            self.m_view:refreshGroupList()
        end
    end
    local params = { vsn = self.m_model:getVersion(), group_ids = group_ids }
    self.m_model:getNetData("gift_group_list", params, callback)
end

function M:refreshMySelfList()
    local function callback(response)
        if self:activityOverExamine(response) then
            return
        end
        self.m_model:updateSelfGroupList(response.groups)
        self.m_model:setTotalTimes(response.total_pay_times)
        self.m_model:setTotalPayValue(response.self_total_payment)
        if self.m_model:getSelIndex() == 2 then
            self.m_view:refreshSelfList()
        end
    end
    local params = { vsn = self.m_model:getVersion() }
    self.m_model:getNetData("gift_my_group_list", params, callback)
end

function M:updateTime()
    if self.m_model:getSelIndex() == 1 and self.m_view.m_cur_tab_node then
        local group_ids = self.m_model:getRefreshGroupId()
        if group_ids and #group_ids > 0 then
            self:refreshGroupList(group_ids, false)
        end
    elseif self.m_model:getSelIndex() == 2 and self.m_view.m_cur_tab_node then
        self:refreshMySelfList()
    end
end

function M:myselfNodeUpdateTime()
    if self.m_model:getSelIndex() == 2 then
        self.m_view:refreshCellTimer()
    end
end

function M:buyItemByChargeId(charge_id)
    if charge_id then
        self.m_view:lockTouch()
        self.timer_id = self:setOnceTimer(8, function()
            if self.m_view then
                self.m_view:unlockTouch()
            end
            self.timer_id = nil
        end)
        PayUtil:rechargeByChargeId(charge_id, function()
            if self.m_view and self.m_model:getSelIndex() == 2 then
                self:refreshMySelfList()
                self.m_view:unlockTouch()
            end
        end)
    end
end

function M:activityOverExamine(response)
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gf_str_0085"), delay_close = 2 })
        self:closeView()
        return true
    end
    return false
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    self:removeTimer(self.m_myselfNode_timer_id)
    M.super.destroy(self)
end

return M
