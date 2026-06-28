local M = class("TopUpGiftBagControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        end
        self:closeView()
    elseif type(msg) == "number" then
        self:switchTabBtn(msg)
    elseif msg == "time_node" then
        self.m_view:switchByTimeNode(data)
    elseif msg == "common_node" then
        self.m_view:switchByCommonNode(data)
    elseif msg == "money_node" then
        self.m_view:switchByMoneyNode(data)
    elseif msg == "buy" then
        self:buyForSDK(data)
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
    elseif msg == "get_free_ladder_gift" then --免费阶梯礼包
        self:getFreeLadderGift(data)
    elseif msg == "get_free_mould_ladder_gift" then --免费阶梯礼包
        self:getFreeMouldLadderGift(data)
    elseif msg == "get_free" then --领取免费超值礼包
        self:getFreeSuper(data)
    elseif msg == "receive_custom_gift" then -- 免费领取定制礼包奖励
        self:getCustomGift(data)
    elseif msg == "get_fund" then --成长基金
        self:getFund(data)
    elseif msg == "getall_royal" then --一键
        self:getAllRoyalReward()
    elseif msg == "getall_warrior" then --一键
        self:getAllHeroicReward()
    elseif msg == "getall_goal_common" then --一键
        self:getAllGoalCommonReward(data)
    elseif msg == "buy_welfare" then --购买新手福利
        self:getBuyWelfare()
    elseif msg == "buy_token" then --购买战令
    elseif msg == "off_all_btn" then
    elseif msg == "get_cmlt_reward" then--累计充值
        self:getCmltReward(data)
    elseif msg == "go_to" then
        static_rootControl:closeAllViewPop()
        local go_type = data or {}
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "open_custom_pop" then -- 打开私人定制弹窗  
        audio:SendEvtUI("UI_Popup_N1")
        self:openView("OperateActivity.CustomMadePop", data)
    elseif msg == "updateCustomData" then
        table.merge(self.m_model.m_custom_data,data.custom_gift)
        self.m_view:refreshUI()
    elseif msg == "get_hero_gift" then
        self:getHeroGiftReward(data)
    elseif msg == "get_equip_gift" then
        self:getEquipGiftReward(data)
    elseif msg == "get_sign_fund" then -- 签到基金
        self:getSignFund(data)
    elseif msg == "quick_sign_fund" then -- 一键签到基金
        self:getQuickSignFund(data)
    elseif msg == "buy_bounty_auto" then -- 悬赏特权
        self:buyBountyAuto()
    elseif msg == "buy_sdk_update" then --    
        self:RefreshOneTagData()
    elseif msg == "btn_one" then --连续充值
        self:openView("OperateActivity.TotllPayPop")
    elseif msg == "btn_two" then --累计充值
        self:openView("OperateActivity.TotalChargePop")
    elseif msg == "btn_1" then
        self:openView("OperateActivity.SpecialOfferPop")
    elseif msg == "get_btn_1" then --领取每日18元奖励
        self:dayBuyReward(data)
    elseif msg == "goto_btn_1" then --跳转特惠礼包
        self:openView("OperateActivity.SpecialOfferPop")
    elseif msg == "Received_btn_1" then --跳转特惠礼包
        self:openView("OperateActivity.SpecialOfferPop")
    elseif msg == "buy_btn_1" then --超值礼包购买
        self:buyForSDK(self.m_model.recommend_node1_charge_id)
        self:switchRecommendNode()
    elseif msg == "buy_btn_2" then --超值礼包购买
        self:buyForSDK(self.m_model.recommend_node2_charge_id)
        self:switchRecommendNode()
    elseif msg == "buy_btn_3" then --限时礼包、推荐礼包
        self:buyForSDK(self.m_model.recommend_node3_charge_id)
        self:switchRecommendNode()
    elseif msg == "refreshRecommendNode" then --关闭特惠礼包刷新
        self:switchRecommendNode()
    elseif msg == "refreshUI" then --关闭特惠礼包刷新
        self.m_view:refreshUI()
    elseif msg == "shop_btn" then
        self:openView("TopUpGiftBag.TopUpShopPop", {is_tokens = self.m_model.is_tokens})
    elseif msg == "updateNewNet" then
        self:RefreshTagData()
    elseif msg == "get_common_grow_up_gift" then
        self:getCommonGrowUpGiftReward(data)
    end
end

--领取每日18元
function M:dayBuyReward(data)
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        self.m_view.m_cur_tab_node:updateGetRewardData(response)
        self:switchRecommendNode()
    end
    local params = {incr_vsn = self.m_model.m_incr_vsn}
    self.m_model:getNetData("user_payment_daily_charge_receive", params, netCallback)
end

--刷新推荐页
function M:switchRecommendNode()
    --self.m_view:switchTabNode(1)
    self:RefreshOneTagData()
    self.m_view:refreshUI()
end

-- tab按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index, function()
            self.m_view:refreshUI()
        end)
    end
end


--调用sdk充值
function M:buyForSDK(charge_id)
    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            self:RefreshOneTagData()
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
        if self.m_view then
            self.m_view:unlockTouch()
            if self.timer_id then
                self:removeTimer(self.timer_id)
                self.timer_id = nil
            end
            self:RefreshOneTagData()
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
        table.merge(self.m_model.m_hero_gift_data,response.gifts_detail)
        self.m_view:refreshUI()
    end
    local params = {
        version = data.version,
        gift_id = data.id
    }
    self.m_model:getNetData("receive_hero_gift", params, receivetCallback)
end

--神兵成长礼包-领取免费礼包
function M:getEquipGiftReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_equip_gift_data,response.gifts_detail)
        self.m_view:refreshUI()
    end
    local params = {
        version = data.version,
        gift_id = data.id
    }
    self.m_model:getNetData("receive_equip_gift", params, receivetCallback)
end

--通用成长礼包-领取免费礼包
function M:getCommonGrowUpGiftReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_growth_gift_data,response.gifts_detail)
        self.m_view:refreshUI()
    end
    local params = {
        version = data.version,
        gift_id = data.id
    }
    self.m_model:getNetData("receive_growth_gift", params, receivetCallback)
end


--购买悬赏特权
function M:buyBountyAuto(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        UserDataManager.m_subscribe.bounty_auto_etime = response.bounty_auto_etime
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("bounty_auto_buy", nil, receivetCallback)
end

--领取签到基金基金
function M:getSignFund(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        -- self.m_model.m_sign_data = response
        table.merge(self.m_model.m_sign_data,response)
        self.m_view:refreshUI()
    end
    local params = {
        day = data.day,
        high = data.high,
        incr_vsn = data.version
    }
    self.m_model:getNetData("sign_fund_receive", params, receivetCallback)
end

--一键领取签到基金基金
function M:getQuickSignFund(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        -- self.m_model.m_sign_data = response
        table.merge(self.m_model.m_sign_data,response)
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
        -- self.m_model.m_cmlt_recharge_data = response.cmlt_recharge
        -- self.m_model.m_cmlt_actives= response.actives
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
        -- self.m_model.m_bright_data = response
        table.merge(self.m_model.m_bright_data, response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = self.m_model.m_bright_data.version
    self.m_model:getNetData("receive_bright_bless", params, receivetCallback)
end

--连续充值
function M:getReward_Continuous(data)
    local function callback(response)
        -- self.m_model.m_continuous_data = response.continuous_payment
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
        -- self.m_model.m_gift_off_data = response.gift_off
        table.merge(self.m_model.m_gift_off_data, response.gift_off)
        self.m_view:refreshUI()
    end
    local params = {}
    params.version = data.vsn
    params.reward_id = data.id
    self.m_model:getNetData("receive_gift_off", params, receivetCallback)
end


--免费阶梯礼包
function M:getFreeLadderGift(data)
    local function receivetCallback(response)
        if response then
            self:netCheckEndTips(response)
            RewardUtil:rewardTipsByData(response.reward)
            -- self.m_model.m_everyDay_ladder_actives = response.actives
            -- self.m_model.m_everyDay_ladder_data = response.data
            -- self.m_model.m_everyDay_charge_sum = response.charge_sum
            if data.open_id == 196 then
                table.merge(self.m_model.m_ladder_actives, response.actives)
                table.merge(self.m_model.m_ladder_data, response.data)
                self.m_model.m_charge_sum = response.charge_sum
            elseif  data.open_id == 202 then 
                table.merge(self.m_model.m_ladder_actives, response.actives)
                table.merge(self.m_model.m_ladder_data, response.data)
                self.m_model.m_charge_sum = response.charge_sum
            elseif data.open_id == 200 then   
                table.merge(self.m_model.m_everyDay_ladder_actives, response.actives)
                table.merge(self.m_model.m_everyDay_ladder_data, response.data) 
            elseif data.open_id == 201 then  
                table.merge(self.m_model.m_everyWeek_ladder_actives, response.actives)
                table.merge(self.m_model.m_everyWeek_ladder_data, response.data)  
            end
            self.m_model.m_everyDay_charge_sum =  response.charge_sum
            if self.m_view.m_cur_tab_node then
                self.m_view.m_cur_tab_node:refreshUI(data.open_id)
            end
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.vsn = data.vsn
    params.place = data.id
    params.open_id = data.open_id
    self.m_model:getNetData("gift_value_daily_recv", params, receivetCallback)
end
--免费阶梯礼包
function M:getFreeMouldLadderGift(data)
    local function receivetCallback(response)
        if response then
            self:netCheckEndTips(response)
            RewardUtil:rewardTipsByData(response.reward)
            table.merge(self.m_model.m_ladder_actives, response.actives)
            table.merge(self.m_model.m_ladder_data, response.gift_mould)
            self.m_model.m_charge_sum = response.charge_sum
            if self.m_view.m_cur_tab_node then
                self.m_view.m_cur_tab_node:refreshUI(data.open_id)
            end
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.vsn = data.vsn
    params.place = data.place
    self.m_model:getNetData("gift_mould_daily_recv", params, receivetCallback)
end

--领取免费超值礼包
function M:getFreeSuper(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        -- self.m_model.m_supervalu_data = response.gift_data
        table.merge(self.m_model.m_supervalu_data, response.gift_data)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data.reward_id
    params.type = data.type
    params.incr_vsn = data.incr_vsn
    self.m_model:getNetData("receive_gift_supervalue", params, receivetCallback)
end

function M:getCustomGift(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_custom_data, response.custom_gift)
        table.merge(self.m_model.m_custom_actives, response.actives)
        self.m_view:refreshUI()
    end
    local params = {}
    params.gift_id = data.gift_id
    params.version = data.version
    self.m_model:getNetData("receive_custom_gift", params, receivetCallback)
end

--领取基金
function M:getFund(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        -- self.m_model.m_war_fund_receiced_data = response
        table.merge(self.m_model.m_war_fund_receiced_data, response)
        self.m_view:refreshUI()
    end
    if self.m_model.m_war_fund_receiced_data.fund_status == 1 then
        self.m_model:getNetData("receive_fund_reward", {fund_id = data.fund_id, reward_id = data.reward_id}, receivetCallback)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0542"), delay_close = 2})
    end
end

--领取皇家犒赏令
function M:getRoyalReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        -- self.m_model.m_war_older_data = response
        table.merge(self.m_model.m_war_older_data, response)
        self:netCheckEndTips(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data
    self.m_model:getNetData("receive_royal_reward", params, receivetCallback)
end

--领取勇者犒赏令
function M:getHeroicReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        -- self.m_model.m_war_older_data = response
        table.merge(self.m_model.m_war_older_data, response)
        self:netCheckEndTips(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data
    self.m_model:getNetData("receive_warrior_reward", params, receivetCallback)
end

--领取侠客岛令
function M:getGoalCommonReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        -- self.m_model.m_war_older_data = response
        table.merge(self.m_model.m_war_older_data, response)
        self:netCheckEndTips(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("receive_goal_common_reward", data, receivetCallback)
end
--一键领取皇家犒赏令
function M:getAllRoyalReward()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.m_war_older_data, response)
        self:netCheckEndTips(response)
        self.m_view:refreshUI()
    end
    local params = {}
    self.m_model:getNetData("auto_receive_royal_reward", params, receivetCallback)
end

--一键领取领取勇者犒赏令
function M:getAllHeroicReward()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.m_war_older_data, response)
        self:netCheckEndTips(response)
        self.m_view:refreshUI()
    end
    local params = {}
    self.m_model:getNetData("auto_receive_warrior_reward", params, receivetCallback)
end

--一键领取侠客岛令
function M:getAllGoalCommonReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.m_war_older_data, response)
        self:netCheckEndTips(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("auto_receive_goal_common_reward", data, receivetCallback)
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
    self.m_view:updateActiveEndTs()
    if self.m_model.m_refresh_time > 0 and self.m_model.is_refresh_bl == false and UserDataManager:getServerTime() > (self.m_model.m_refresh_time +1) then
        self:updateMsg("updateNewNet")
        self.m_model.is_refresh_bl = true
    end
end

function M:getTagCfg(open_Id)
    return self.m_view:getTagCfg(open_Id)
end

-- 不是每日阶梯礼包就是每周阶梯礼包
function M:isEveryDayLadderGifBag(open_Id)
    return self.m_model:isEveryDayLadderGifBag(open_Id)
end

--统一刷新数据
function M:RefreshTagData()
    local select_open_id = 0 --记录刷新前选中的活动
    local last_index = self.m_model.m_sel_tab_index or 1
    if self.m_model.tag_table[self.m_model.m_sel_tab_index] then
        select_open_id = self.m_model.tag_table[self.m_model.m_sel_tab_index].open_id
    end
    self.m_model:refreshData(function ()
        local active_have = false --刷新后检查当前活动是否还存在
        for k, v in pairs(self.m_model.tag_table) do
            if v.open_id == select_open_id then
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
    if self.m_model.tag_table[self.m_model.m_sel_tab_index] then
        active_id = self.m_model.tag_table[self.m_model.m_sel_tab_index].id or 1
    end
    local last_index = self.m_model.m_sel_tab_index or 1
    self.m_model:refreshData(function ()
        local active_have = false --活动是否还存在
        if self.m_model.m_sel_tab_index == 1 then --推荐页签--必然存在
            active_have = true
        else
            for k, v in pairs(self.m_model.tag_table) do
                if v.id == active_id then
                    active_have = true
                end
            end
        end
        if active_have == false then
            if active_have == false then-- 如果选中活动结束 重置索引
                self.m_model.m_sel_tab_index = last_index > #self.m_model.tag_table and #self.m_model.tag_table or last_index
            end
            if self.m_view.cur_tab[self.m_model.m_sel_tab_index].open_id == 82 then --活动结束删除对应open_id的索引
               self.m_model:deletActive(82)
            end
            self.m_view:refreshActiveEndUI()
            return
        end
        local data = self.m_view.cur_tab[self.m_model.m_sel_tab_index]
        if data == nil then
            return
        end
        local btn_tab = self.m_view:getTagCfg(data.open_id)
        if btn_tab == nil then
            return
        end
        self.m_model:refreshTabData(btn_tab.open_id, btn_tab.net_url)
        local url_data = nil
        if btn_tab.open_id == 83 then --日礼包
            url_data = 1
        elseif btn_tab.open_id == 110 then --周礼包    
            url_data = 2
        elseif btn_tab.open_id == 111 then -- 月礼包
            url_data = 3
        else
            url_data = data.open_id
        end
        self.m_view.m_cur_tab_node:switchUI(url_data, data.id)
    end)
end


function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {self, self.dataUpdateEvent})
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
