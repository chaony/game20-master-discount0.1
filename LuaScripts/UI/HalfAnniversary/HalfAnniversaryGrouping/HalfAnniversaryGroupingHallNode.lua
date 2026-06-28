---@field m_model HalfAnniversaryGroupingModel
local M = class("HalfAnniversaryGroupingHallNode", LikeOO.OOUIbase)
M.m_uiName = "HalfAnniversary/HalfAnniversaryGroupingHallNode"

function M:onEnter()
    self:bindUI()
    self:refreshUI()
end

function M:refreshUI()
    self:refreshGroupList()
    self:refreshSearchPanel()
end

function M:bindUI()
    self:setTextByLanKey("input_placeholder", "gift_group_text_0010")
    self:setTextByLanKey("search_text", "gift_group_text_0010")
    self:setTextByLanKey("refresh_text", "gift_group_text_0011")
    self:setTextByLanKey("title_text", "gift_group_text_0005")
    self:setTextByLanKey("txt_sort_1", "gift_group_text_0006")
    self:setTextByLanKey("txt_sort_2", "gift_group_text_0007")
    self:setTextByLanKey("txt_sort_3", "gift_group_text_0008")
    self:setTextByLanKey("money_text", "gift_group_text_0013")
    self:setTextByLanKey("empty_text", "gift_group_text_0036")
    self.m_input = self:findInputField("input")
    self.sortList_go = self:findGameObject("sort_list")
    local gray_img = self:findImage("gray_img")
    self.m_gray_material = gray_img.material
    local normal_img = self:findImage("join_btn")
    self.m_normal_material = normal_img.material
end

function M:showSortPanel()
    local isOpenSearch = self.m_model:getSearchState()
    self:setObjectVisible("sort_select_btn", isOpenSearch)
    self:setObjectVisible("sort_list", isOpenSearch)

end

function M:refreshGroupList()
    local group_data = self.m_model:getGroupList()
    local isEmpty = #group_data <= 0
    self:setObjectVisible("empty_node", isEmpty)
    self:setObjectVisible("loopscroll", not isEmpty)
    if not isEmpty then
        self:refreshLoopScroll(group_data)
    end
end

function M:refreshSearchPanel()
    local isOpenSearch = self.m_model:getSearchState()
    self.sortList_go:SetActive(isOpenSearch)
end

function M:setSearchPanelState(state)
    self.m_cur_state = state
    self:refreshSearchPanel()
end

function M:getSearchId()
    return self.m_input.text
end

function M:resetSearchInfo()
    self.m_input.text = ""
end

function M:refreshLoopScroll(group_data)
    self.m_click_cell_object = nil
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = group_data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "join_btn" then
                    if #cell_data.pay_uids >= cell_data.max_member then
                        GameUtil:lookInfoTips(self.m_control, { msg = Language:getTextByKey("gift_group_text_0037"), delay_close = 2 })
                        return
                    elseif cell_data.self_in == 1 then
                        GameUtil:lookInfoTips(self.m_control, { msg = Language:getTextByKey("gift_group_text_0034"), delay_close = 2 })
                        return
                    elseif cell_data.has_same_gift == 1 then
                        GameUtil:lookInfoTips(self.m_control, { msg = Language:getTextByKey("gift_group_text_0035"), delay_close = 2 })
                        return
                    end
                    self:updateMsg("join_btn", cell_data.group_id)
                end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(group_data, true)
    end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local data = cell_data
    local reward_node = luaBehaviour:FindRectTransform("reward_node")
    local pay_num = #data.pay_uids or 0
    local return_num = 0
    local need_num = 0
    local isMax = #data.pay_uids >= data.max_member
    local phase = self.m_model:getCurDayPhaseConfigByGiftId(data.gift_id)
    if not phase then
        return
    end

    for k, v in ipairs(phase) do
        if v.phase > pay_num then
            need_num = v.phase - pay_num
            return_num = v.rtn
            break
        elseif k == #data then
            need_num = 0
            return_num = v.rtn
        end
    end
    GameUtil:createRewards(reward_node, data.reward, true, true, nil, 1)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "money_text", "gift_group_text_0013", data.price)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "id_text", "gift_group_text_0016", data.group_id)

    local join_btn_img = luaBehaviour:FindImage("join_btn")
    if data.self_in == 1 or data.has_same_gift == 1 or isMax then
        join_btn_img.material = self.m_gray_material
    else
        join_btn_img.material = self.m_normal_material
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"info_text2",not isMax)
    if isMax then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "info_text1", "gift_group_text_0038")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "info_text2", "gift_group_text_0015", need_num)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "info_text1", "gift_group_text_0014", return_num)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M