---@class OperateActivityControl:OOControlBase
---@field m_view OperateActivityView
local M = class("OperateActivityControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {self, self.dataUpdateEvent})
    audio:SendEvtUI("UI_HuoDong")
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        end
        if self.ref_buy_token and self.ref_buy_token == true then
            self:updateMsg("update_task_token", nil, "Task")
        end
        self:closeView()
    elseif type(msg) == "number" then
        self:switchTabBtn(msg)
    elseif msg == "switch_tab" then
        self:switchTabBtn(data.index, data.cell_object)
    elseif msg == "time_node" then
        self.m_view:switchByTimeNode(data)
    elseif msg == "common_node" then
        self.m_view:switchByCommonNode(data)
    elseif msg == "money_node" then
        self.m_view:switchByMoneyNode(data)
    elseif msg == "buy" then
        self:buyForSDK(data)
    elseif msg == "buy_high_token" then
        self.ref_buy_token = true
        self:buyForSDK(data, function ()
            self.ref_buy_token = true
        end)
    elseif msg == "buy_subscribe" then
        self:buySubscribe(data)
    elseif msg == "vip_btn" then
        self:openView("Pops.CommonVipShowPop")
    elseif msg == "get_reward" then
    elseif msg == "cat_7_btn" then
        self:openView("Pops.Category7Pop")
    elseif msg == "receive_continuous" then
        self:getReward_Continuous(data)
    elseif msg == "get_seven_reward" then
        self:getSeven_Tour()
    elseif msg == "get_daily_reward" then
        self:getDayily(data)
    elseif msg == "recharge_daily_reward" then
        self:getRechargeDayily(data)
    elseif msg == "box_daily_reward" then
        self:getBoxDayily(data)
    elseif msg == "hero_receive" then
        self:requestReceive(data)
    elseif msg == "get_btn" then
        self:getOnTimeReward()
    elseif msg == "get_royal_reward" then
        self:getRoyalReward(data)
    elseif msg == "get_warrior_reward" then
        self:getHeroicReward(data)
    elseif msg == "get_goal_common_reward" then
        self:getGoalCommonReward(data)
    elseif msg == "get_gift_off" then --特惠礼包
        self:getGiftOff(data)
    elseif msg == "get_free" then --领取免费超值礼包
        self:getFreeSuper(data)
    elseif msg == "get_fund" then --成长基金
        self:getFund(data)
    elseif msg == "get_quick_fund" then--一键成长基金
        self:getQuickFund()
    elseif msg == "getall_royal" then --一键
        self:getAllRoyalReward(data)
    elseif msg == "getall_warrior" then --一键
        self:getAllHeroicReward(data)
    elseif msg == "getall_goal_common" then --一键
        self:getAllGoalCommonReward(data)
    elseif msg == "buy_welfare" then --购买新手福利
        self:getBuyWelfare()
    elseif msg == "buy_token" then --购买战令
    elseif msg == "update_token" then --购买战令等级刷新    
        self.m_model:setWarOlderData(data)
        self.m_view:refreshUI()
    elseif msg == "off_all_btn" then
    elseif msg == "get_cmlt_reward" then--累计充值
        self:getCmltReward(data)
    elseif msg == "go_to" then
        static_rootControl:closeAllViewPop()
        local go_type = data or {}
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "open_custom_pop" then -- 打开私人定制弹窗   
        self:openView("OperateActivity.CustomMadePop", data)
    elseif msg == "updateCustomData" then
        self.m_model.m_custom_data = data.custom_gift
        self.m_view:refreshUI()
    elseif msg == "get_hero_gift" then
        self:getHeroGiftReward(data)
    elseif msg == "get_sign_fund" then -- 签到基金
        self:getSignFund(data)
    elseif msg == "quick_sign_fund" then -- 一键签到基金
        self:getQuickSignFund(data)
    elseif msg == "buy_bounty_auto" then -- 悬赏特权
        self:buyBountyAuto()
    elseif msg == "get_gacha_auto" then -- 抽卡特权
        self:getGaChaAuto()
    elseif msg == "buy_sdk_update" then --    
        self:RefreshOneTagData()
    elseif msg == "updateFundData" then --    
        self.m_model.m_fund_data = data
        self.m_view:refreshUI()
    elseif msg == "updateFundData2" then --    
        self.m_model.m_fund_data.normal_sign_fund = data.normal_sign_fund
        self.m_model.m_fund_data.high_sign_fund = data.high_sign_fund
        self.m_view:refreshUI()
    elseif msg == "active_month" then
        --[[
        local function receivetCallback(response)
            RewardUtil:rewardTipsByData(response.reward)
            self:netCheckEndTips(response)
            table.merge(self.m_model.m_month_card_data.month_card, response.month_card)
            self.m_view:refreshUI()
        end
        ]]--
        self:buyForSDK(data)
        --[[
        if data == 1 then
            self:activeWeekCard()
        else
            self:activeMonthCard()
        end
        --]]
    elseif msg == "updateNewNet" then
        self:RefreshTagData()
    elseif msg == "rivers_btn" then
        local activeData = UserDataManager:getActivesDataByOpenId(401)
        if not activeData then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fukubukuroku_text_0008"), delay_close = 2})
            return
        end
        self:openView("Fukubukuroku.FukubukurokuMain")
    elseif msg == "update_red" then
        self.m_view:UpdateRedStatus()
    end
end

-- tab按钮切换
function M:switchTabBtn(index,obj)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index,obj)
    end
end

--调用sdk充值
function M:buyForSDK(charge_id, callback)
    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            if callback then
                callback()
            end
            self:RefreshOneTagData()
        end)
        return
    end
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        if callback then
            callback()
        end
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(8, function ()
        self.m_view:unlockTouch()
        if callback then
            callback()
        end
        self.timer_id = nil
    end)
    PayUtil:rechargeByChargeId(charge_id, function ()
        if self.m_view then
            if callback then
                callback()
            end
            if self.timer_id then
                self:removeTimer(self.timer_id)
                self.timer_id = nil
            end
            self.m_view:unlockTouch()
            self:RefreshOneTagData()
        end
        if self.m_view then
            self.m_view:unlockTouch()
        end
        self:RefreshOneTagData()
    end)
end

--特权礼包购买
function M:buySubscribe(charge_id)
    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            if self.m_view then
                self.m_view:refreshUI() 
            end
            EventDispatcher:dipatchEvent("subscribe_buy_event", {event = "fresh_ui"})
        end)
        return
    end
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(8, function ()
        self.m_view:unlockTouch()
        self.timer_id = nil
    end)
    PayUtil:rechargeByChargeId(charge_id, function ()
        if self.timer_id then
            self:removeTimer(self.timer_id)
            self.timer_id = nil
        end
        if self.m_view then
            self.m_view:unlockTouch()
            self.m_view:refreshUI()
            EventDispatcher:dipatchEvent("subscribe_buy_event", {event = "fresh_ui"})
        end
    end)
end

--使用代金券购买
function M:buyUseVoucher(data, callback)
    local function receivetCallback(response)
        if callback then 
            callback()
        end
        if response and response.reward then 
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local charge = ConfigManager:getCfgByName("charge")
    local cfg = charge[data]
    if cfg == nil then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0129",data), delay_close = 2})
        return
    end
    local voucher_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.VOUCHER,0,0})
    if voucher_data.user_num < cfg.price then 
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0130",data), delay_close = 2})
        return
    end
    local params = {
        charge_id = data
    }
    self.m_model:getNetData("voucher", params, receivetCallback)
end

--英雄成长礼包-领取免费礼包
function M:getHeroGiftReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_hero_gift_data, response.gifts_detail)
        table.merge(self.m_model.m_hero_gift_actives, response.actives)
        self.m_view:refreshUI()
    end
    local params = {
        version = data.version,
        gift_id = data.id
    }
    self.m_model:getNetData("receive_hero_gift", params, receivetCallback)
end

--周卡激活 废弃
function M:activeWeekCard()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_month_card_data.week_card, response.week_card)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("open_week_card", nil, receivetCallback)
end

--月卡激活 废弃
function M:activeMonthCard()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_month_card_data.month_card, response.month_card)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("open_month_card", nil, receivetCallback)
end

--购买悬赏特权
function M:buyBountyAuto(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        UserDataManager.m_subscribe.bounty_auto_etime = response.bounty_auto_etime
        EventDispatcher:dipatchEvent("subscribe_buy_event", {event = "fresh_ui"})
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("bounty_auto_buy", nil, receivetCallback)
end

--领取招募特权
function M:getGaChaAuto()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(UserDataManager.m_sub_received, response.sub_received)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("recv_subscribe_reward", nil, receivetCallback)
end

function M:popWakeUp(pop_flag, page_type, page_data)
    local show_flag = RedPointUtil:localRedPointJudge(pop_flag)
    if show_flag then
        local params = {
            pop_flag = {pop_flag},
            page_data = {page_data},
            page_type = {page_type}
        }
        self:openView("OperateActivity.WakeUpFundPop", params)
    end
end

function M:canPopWakeUp(reason_id, server_data_lv)
    local popup_reason = ConfigManager:getCfgByName("popup_reason") or {}
    local need_lv_tab = popup_reason[reason_id] or { }
    for i = #need_lv_tab, 1, -1 do
        local need_lv = need_lv_tab[i]
        if server_data_lv == need_lv then
            return true
        end
    end
    return false
end

--领取签到基金基金
function M:getSignFund(data)
    local function receivetCallback(response)
        local function goWakeUp()
            local opened_lv = response.sign_fund and response.sign_fund.opened_lv or 2
            local reason_id = 0
            if opened_lv == 0 then
                reason_id = 2
            elseif opened_lv == 1 then
                reason_id = 3
            end
            local days = data.day or 0
            if reason_id ~= 0 and self:canPopWakeUp(reason_id, days) then
                self:popWakeUp("sign_fund_pop_flag", "sign_fund", self.m_model.m_fund_data)
            end
        end
        self:netCheckEndTips(response)
        --self.m_model.m_fund_data.sign_fund = response.sign_fund
        table.merge(self.m_model.m_fund_data.sign_fund, response.sign_fund)
        RewardUtil:rewardTipsByData(response.reward, nil , goWakeUp)

        self.m_view:refreshUI()
    end
    local params = {
        day = data.day,
        incr_vsn = data.version
    }
    self.m_model:getNetData("sign_fund_receive", params, receivetCallback)
end

--一键领取签到基金基金
function M:getQuickSignFund(data)
    local function receivetCallback(response)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_fund_data.normal_sign_fund, response.normal_sign_fund)
        table.merge(self.m_model.m_fund_data.high_sign_fund, response.high_sign_fund)
        local function goWakeUp()
            local opened_lv = response.sign_fund and response.sign_fund.opened_lv or 2
            local reason_id = 0
            if opened_lv == 0 then
                reason_id = 2
            elseif opened_lv == 1 then
                reason_id = 3
            end
            local days = response.sign_fund and response.sign_fund.days or 0
            if reason_id ~= 0 and self:canPopWakeUp(reason_id, days) then
                self:popWakeUp("sign_fund_pop_flag", "sign_fund", self.m_model.m_fund_data)
            end
        end
        RewardUtil:rewardTipsByData(response.reward, nil, goWakeUp)
        self.m_view:refreshUI()
    end
    local params = {
        high = data.high,
        incr_vsn = data.version
    }
    self.m_model:getNetData("sign_fund_auto_receive", params, receivetCallback)
end

--领取累计充值
function M:getCmltReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_cmlt_recharge_data, response.cmlt_recharge)
        table.merge(self.m_model.m_cmlt_actives, response.actives)
        self.m_view:refreshUI()
    end
    local params = {
        gift_id = data,
        incr_vsn = self.m_model.m_cmlt_recharge_data.incr_vsn or self.m_model.m_cmlt_recharge_data.version or 1
    }
    self.m_model:getNetData("receive_cmlt_recharge", params, receivetCallback)
end

--领取新手福利
function M:getBuyWelfare()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_bright_data, response)
        -- self.m_model.m_bright_data = response
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = self.m_model.m_bright_data.version
    self.m_model:getNetData("receive_bright_bless", params, receivetCallback)
end

--连续充值
function M:getReward_Continuous(data)
    local function callback(response)
        table.merge(self.m_model.m_continuous_data, response.continuous_payment)
        self:netCheckEndTips(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.day = data
    self.m_model:getNetData("receive_continuous", params, callback)
end

--领取特惠礼包
function M:getGiftOff(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_gift_off_data, response.gift_off) 
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data
    self.m_model:getNetData("receive_gift_off", params, receivetCallback)
end

--领取免费超值礼包
function M:getFreeSuper(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_supervalu_data, response.gift_data) 
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data.reward_id
    params.type = data.type
    self.m_model:getNetData("receive_gift_supervalue", params, receivetCallback)
end

--领取基金
function M:getFund(data)
    local function receivetCallback(response)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_fund_data, response) 
        
        local function goWakeUp()
            local fund_status =response.fund_status or 1
            if fund_status == 0 and response.fund_quests[tostring(data.reward_id)] then
                local cur_lv = response.fund_quests[tostring(data.reward_id)].value
                local reason_id = 4
                if self:canPopWakeUp(reason_id, cur_lv) then
                    self:popWakeUp("grow_fund_pop_flag", "grow_fund", self.m_model.m_fund_data)
                end
            end
        end
        RewardUtil:rewardTipsByData(response.reward, nil, goWakeUp)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("receive_fund_reward", {reward_id = data.reward_id, open_id = data.open_id}, receivetCallback)
end

--一键领取基金
function M:getQuickFund(data)
    local function receivetCallback(response)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_fund_data, response)
        local function goWakeUp()
            local fund_status =response.fund_status or 1
            if fund_status == 0 and response.fund_quests[tostring(data.reward_id)] then
                local cur_lv = response.fund_quests[tostring(data.reward_id)].value
                local reason_id = 4
                if self:canPopWakeUp(reason_id, cur_lv) then
                    self:popWakeUp("grow_fund_pop_flag", "grow_fund", self.m_model.m_fund_data)
                end
            end
        end
        RewardUtil:rewardTipsByData(response.reward, nil, goWakeUp)
        self.m_view:refreshUI()
    end
    if self.m_model.m_fund_data.fund_status == 1 then
        self.m_model:getNetData("auto_receive_fund", nil, receivetCallback)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0542"), delay_close = 2})
    end
end

--领取皇家犒赏令
function M:getRoyalReward(data)
    local function receivetCallback(response)
        self.ref_buy_token = true
        self:netCheckEndTips(response)
        self.m_model:mergeWarOlderData(response)
        local function goWakeUp()
            local fund_status =response.valor_payment_status or 1
            if fund_status == 0 then
                local cur_lv = data.id
                local reason_id = 1
                if self:canPopWakeUp(reason_id, cur_lv) then
                    self:popWakeUp("war_order_pop_flag", "war_order", self.m_model.m_war_older_data)
                end
            end
        end
        RewardUtil:rewardTipsByData(response.reward, nil, goWakeUp)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data.id
    params.vsn = data.vsn
    self.m_model:getNetData("receive_royal_reward", params, receivetCallback)
end

--领取勇者犒赏令
function M:getHeroicReward(data)
    local function receivetCallback(response)
        self.ref_buy_token = true
        self:netCheckEndTips(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:mergeWarOlderData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data.id
    params.vsn = data.vsn
    self.m_model:getNetData("receive_warrior_reward", params, receivetCallback)
end

function M:getGoalCommonReward(data)
    local function receivetCallback(response)
        self.ref_buy_token = true
        self:netCheckEndTips(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:mergeWarOlderData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("receive_goal_common_reward", data, receivetCallback)
end

--一键领取皇家犒赏令
function M:getAllRoyalReward(data)
    local can_get_id_tab = self.m_model:getNotGetRoyalReward()
    local function receivetCallback(response)
        self.ref_buy_token = true
        self.m_model:mergeWarOlderData(response)
        self:netCheckEndTips(response)
        local function goWakeUp()
            local fund_status =response.valor_payment_status or 1
            if fund_status == 0 then
                local reason_id = 1
                for cur_lv = #can_get_id_tab, 1, -1  do
                    if self:canPopWakeUp(reason_id, cur_lv) then
                        self:popWakeUp("war_order_pop_flag", "war_order", self.m_model.m_war_older_data)
                        break
                    end
                end
            end
        end
        RewardUtil:rewardTipsByData(response.reward, nil, goWakeUp)
        self.m_view:refreshUI()
    end
    local params = {}
    params.vsn = data
    self.m_model:getNetData("auto_receive_royal_reward", params, receivetCallback)
end

--一键领取领取勇者犒赏令
function M:getAllHeroicReward(data)
    local function receivetCallback(response)
        self.ref_buy_token = true
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:mergeWarOlderData(response)
        self:netCheckEndTips(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.vsn = data
    self.m_model:getNetData("auto_receive_warrior_reward", params, receivetCallback)
end

--一键领取侠客岛令
function M:getAllGoalCommonReward(data)
    local function receivetCallback(response)
        self.ref_buy_token = true
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:mergeWarOlderData(response)
        self:netCheckEndTips(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("auto_receive_goal_common_reward", data, receivetCallback)
end

--每日
function M:getDayily(data)
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        table.merge(self.m_model.m_sign_daily_data, response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("receive_sign_daily", nil, callback, nil)
end

--每日充值
function M:getRechargeDayily(data)
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        table.merge(self.m_model.m_sign_daily_data, response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.day = data
    self.m_model:getNetData("receive_recharge_sign_daily", params, callback, nil)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "charge" then
        if data.add_token and data.add_token == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("充值失败！"), delay_close = 2})
            return
        end
        self:RefreshOneTagData()
    end
end

function M:netCheckEndTips(response)
    if response.update == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
    end
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:RefreshTagData()
    end
end

function M:testRemoveCurTag()
    self.m_model:removeCurActives()
    self.m_model:refreshActiveEnd()
    self.m_view:refreshActiveEndUI()
end

function M:updateTime()
    self.m_view:updateTime()
    if self.m_model.m_refresh_time > 0 and self.m_model.is_refresh_bl == false and UserDataManager:getServerTime() >= self.m_model.m_refresh_time then
        self:updateMsg("updateNewNet")
        self.m_model.is_refresh_bl = true
    end
end

--统一刷新数据
function M:RefreshTagData()
    local select_open_id = 0 --记录刷新前选中的活动
    local last_index = self.m_model.m_sel_tab_index or 1
    if self.m_model.tag_table[self.m_model.m_sel_tab_index] then
        select_open_id = self.m_model.tag_table[self.m_sel_tab_index]
    end
    self.m_model:refreshData(function ()
        local active_have = false --刷新后检查当前活动是否还存在
        for k, v in pairs(self.m_model.tag_table) do
            if v == select_open_id then
                self.m_model.m_sel_tab_index = k --重置当前索引 有可能开启新的活动
                active_have = true
            end
        end
        if active_have == false then-- 如果选中活动结束 重置索引
            self.m_model.m_sel_tab_index = last_index > #self.m_model.tag_table and 1 or last_index
        end
        self.m_view:refreshActiveEndUI()
        self.m_model.is_refresh_bl = false
        if next(self.m_model.tag_table) == nil then
            self:updateMsg(99999)
        end 
    end)
end


--刷新数据只刷新本界面
function M:RefreshOneTagData()
    local active_id = 0
    if self.m_model then
        if self.m_model.tag_table[self.m_model.m_sel_tab_index] then
            active_id = self.m_model.tag_table[self.m_model.m_sel_tab_index]
        end
        local last_index = self.m_model.m_sel_tab_index or 1
        self.m_model:refreshData(function ()
            local active_have = false --活动是否还存在
            for k, v in pairs(self.m_model.tag_table) do
                if v == active_id then
                    active_have = true
                end
            end
            if active_have == false then
                if active_have == false then-- 如果选中活动结束 重置索引
                    self.m_model.m_sel_tab_index = last_index > #self.m_model.tag_table and #self.m_model.tag_table or last_index
                end
                self.m_view:refreshActiveEndUI()
                return
            end
            local data = self.m_view.cur_tab[self.m_model.m_sel_tab_index]
            if data == nil then
                return
            end
            local btn_tab = self.m_view:getSecondaryTagCfg(data)
            if btn_tab == nil then
                return
            end
            self.m_model:refreshTabData(btn_tab.open_id, btn_tab.net_url)
            if self.m_view.m_cur_tab_node.switchUI then
                self.m_view.m_cur_tab_node:switchUI(data)
            end
        end)
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {self, self.dataUpdateEvent})
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
