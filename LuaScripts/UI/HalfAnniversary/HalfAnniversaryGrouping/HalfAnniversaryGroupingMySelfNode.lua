---@field m_model HalfAnniversaryGroupingModel
local M = class("HalfAnniversaryGroupingMySelfNode", LikeOO.OOUIbase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryGroupingMySelfNode"

function M:onEnter()
    self.m_timer_text_list = {}
    self.m_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    self:refreshUI()
end

function M:refreshUI()
    self:bindUI()
    self:refreshMySelfLoopScroll()
    self:refreshCellTimer()
end

function M:bindUI()
    self:setTextByLanKey("title_text", "gift_group_text_0005")
    self:setTextByLanKey("empty_text", "gift_group_text_0036")
end
function M:refreshMySelfLoopScroll()
    local data = self.m_model:getSelfGroupList()
    local isEmpty = #data <= 0
    self:setObjectVisible("empty_node", isEmpty)
    self:setObjectVisible("loopscroll", not isEmpty)
    if isEmpty then
        return
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "abandon_btn" then
                    self:updateMsg("exit_group", cell_data.group_id)
                elseif click_name == "invite_btn" then
                    self:updateMsg("invite_group", { group_id = cell_data.group_id, create_time = cell_data.create_time })
                elseif click_name == "buy_btn" then
                    self:updateMsg("buy", { group_id = cell_data.group_id, charge_id = cell_data.charge_id })
                end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end


-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local data = cell_data
    self.m_timer_text_list[cell_object] = { text = luaBehaviour:FindText("timer_text") }
    local reward_node = luaBehaviour:FindRectTransform("reward_node")
    local ticket_node = luaBehaviour:FindRectTransform("ticket_parent")
    local pay_num = #data.pay_uids or 0
    local return_num = 0
    local need_num = 0
    local isMaxReturn = false
    local isPurchased = false
    local cur_index = 0
    for k, v in ipairs(data.pay_uids) do
        if v == self.m_uid then
            isPurchased = true
            break
        end
    end
    local phase = self.m_model:getCurDayPhaseConfigByGiftId(data.gift_id)
    if not phase then
        return
    end
    for k, v in ipairs(phase) do
        if v.phase > pay_num then
            need_num = v.phase - pay_num
            return_num = v.rtn
            break
        elseif #phase == k and pay_num >= v.phase then
            need_num = 0
            return_num = v.rtn
            isMaxReturn = true
        end
        cur_index = k
    end

    local success_go = luaBehaviour:FindGameObject("success_img")
    local abandon_go = luaBehaviour:FindGameObject("abandon_btn")
    local invite_go = luaBehaviour:FindGameObject("invite_btn")
    local buy_go = luaBehaviour:FindGameObject("buy_btn")
    local purchased_go = luaBehaviour:FindGameObject("purchased_img")
    local top_go = luaBehaviour:FindGameObject("top_go")
    local text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "id_text", "gift_group_text_0033", data.group_id)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", "gift_group_text_0025", data.price)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_text1", "gift_group_text_0017", need_num)
    LuaBehaviourUtil.setText(luaBehaviour, "top_text2", "x" .. return_num)
    GameUtil:createRewards(reward_node, data.reward, true, true, nil, 1)
    --状态
    abandon_go:SetActive(not isPurchased)
    buy_go:SetActive(not isPurchased)
    invite_go:SetActive(isPurchased)
    purchased_go:SetActive(isPurchased)
    top_go:SetActive(not isMaxReturn)
    success_go:SetActive(false)
    if isMaxReturn and isPurchased then
        abandon_go:SetActive(false)
        buy_go:SetActive(false)
        invite_go:SetActive(false)
        purchased_go:SetActive(false)
        success_go:SetActive(true)
    end
    if cur_index > 0 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "gain_text", "gift_group_text_0021")
        local ticket_data = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.VOUCHER, 137, phase[cur_index].rtn })
        GameUtil:createItemElementByData(ticket_data, true, true, nil, ticket_node)
    else
        --显示第一阶段即将获取
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "gain_text", "gift_group_text_0017", need_num)
        local ticket_data = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.VOUCHER, 137, phase[1].rtn })
        GameUtil:createItemElementByData(ticket_data, true, true, nil, ticket_node)
    end


end

function M:refreshCellTimer()
    for k, v in pairs(self.m_timer_text_list) do
        local curTime = UserDataManager:getServerTime()
        local min_unit = 60
        local hour_unit = min_unit * 60
        local time_day_end = TimeUtil.getIntTimestamp(curTime) + hour_unit * 24
        local time_left = time_day_end - curTime
        local hour_left = math.floor(time_left / (hour_unit))
        local min_left = math.floor((time_left - hour_unit * hour_left) / min_unit)
        local sec_left = math.floor(time_left - hour_unit * hour_left - min_unit * min_left)
        local timerFormat = Language:getTextByKey("evil_shadow_str_010", hour_left, min_left, sec_left)
        v.text.text = timerFormat
        --self:setText("timer_text", timerFormat)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M