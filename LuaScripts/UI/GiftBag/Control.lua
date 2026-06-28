local M = class("GiftBagControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    audio:SendEvtUI("UI_FuLi")
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:updateMsg("common_refresh", nil, "parent")
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
        self:openView("Pops.CommonBuyPop", {id = data})
    elseif msg == "buy_growup_btn" then
        --抽签
        self:getDrawRandomDraw(data)
    elseif msg == "buy_royal_btn" then
    elseif msg == "buy_brave_btn" then
        self:openView("Pops.CommonBuyPop", {id = 13})
    elseif msg == "get_com_btn" then --普通月卡
        self:openView("Pops.CommonBuyPop", {id = 9})
    elseif msg == "get_super_btn" then --超级月卡
        self:openView("Pops.CommonBuyPop", {id = 10})
    elseif msg == "vip_btn" then
        self:openView("Pops.CommonVipShowPop")
    elseif msg == "get_reward" then
    elseif msg == "cat_7_btn" then
        self:openView("Pops.Category7Pop")
    elseif msg == "get_seven_reward" then
        self:getSeven_Tour(data)
    elseif msg == "get_daily_reward" then
        self:getDayily(data)
    elseif msg == "recharge_daily_reward" then
        self:getRechargeDayily(data)
    elseif msg == "hero_receive" then
        self:requestReceive(data)
    elseif msg == "hero_active_receive" then
        self:requestActiveReceive(data)
    elseif msg == "get_royal_reward" then
        self:getRoyalReward(data)
    elseif msg == "get_warrior_reward" then
        self:getHeroicReward(data)
    elseif msg == "get_goal_common_reward" then
        self:getGoalCommonReward(data)
    elseif msg == "open_scroll_pop" then
        local params = {
            floor = self.m_model.m_scroll_data.layer,
            big_gift_id = self.m_model.m_scroll_data.big_gift_id,
            version = self.m_model.m_scroll_data.version,
            big_rcvd = self.m_model.m_scroll_data.big_rcvd
        }
        self:openView("GiftBag.GiftScrollSelectPop", params)
    elseif msg == "open_look_scroll" then
        local params = {
            floor = self.m_model.m_scroll_data.layer,
            big_gift_id = self.m_model.m_scroll_data.big_gift_id,
            version = self.m_model.m_scroll_data.version,
            big_rcvd = self.m_model.m_scroll_data.big_rcvd
        }
        self:openView("GiftBag.GiftLookScrollPop", params)
    elseif msg == "get_text" or msg == "jump_task_btn" then
        local params = {
            draw_data = self.m_model.m_draw_data,
            task_data = self.m_model:get_task_data(),
            shop_done = self.m_model:get_task_shop(),
            login_done = self.m_model:get_task_login()
        }
        self:openView("GiftBag.DrawTaskPanel", params)
    elseif msg == "shuoming_gua_btn" then
        local active_tab = ConfigManager:getCfgByName("active")
        local gua_cfg = nil
        for k,v in pairs(active_tab) do
            if v.open_id == 117 then
                gua_cfg = v
            end
        end
        local draw_tab = ConfigManager:getCfgByName("draw")
        local draw_cfg = draw_tab[self.m_model.m_draw_data.version]
        local params = {}
        params.content = draw_cfg.des
        params.title = gua_cfg.name
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "jinnang_ben" then
        local active_tab = ConfigManager:getCfgByName("active")
        local jn_cfg = nil
        for k,v in pairs(active_tab) do
            if v.open_id == 118 then
                jn_cfg = v
            end
        end
        local scroll_tab = ConfigManager:getCfgByName("scroll")
        local scroll_cfg = scroll_tab[self.m_model.m_scroll_data.version]
        local params = {}
        params.content = scroll_cfg.des
        params.title = jn_cfg.name
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "updateBigPrize" then
        self.m_model.m_scroll_data.big_gift_id = data or 0
        self.m_view:refreshUI()
    elseif msg == "open_scroll" then
        if self.m_model.m_scroll_data.big_pos == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0041"), delay_close = 2})
            return
        end
        self:openScroll(data)
    elseif msg == "updateDrawData" then
        table.merge(self.m_model.m_draw_data,data)
        self.m_view:refreshUI()
    elseif msg == "updateScrollData" then
        self.m_model.m_scroll_data.quests = data.quests
    elseif msg == "updateLimitExchange" then
        self.m_model.m_exchange_data.quests = data.quests
    elseif msg == "updateScrollBuyData" then
        self.m_model.m_scroll_data.buy_times = data
    elseif msg == "updateScrollTimes" then
        self.m_model.m_scroll_data.buy_times = data
    elseif msg == "get_ace_pag_btn" then
        local params = {
            version = self.m_model.m_scroll_data.version,
            quests= self.m_model.m_scroll_data.quests,
            buy_times = self.m_model.m_scroll_data.buy_times,
        }
        self:openView("GiftBag.GiftScrollTaskPop", params)
    elseif msg == "go_to" then
        local go_type = data or {}
        local jump = ConfigManager:getCfgByName("jump")
        local jump_item = jump[go_type[1]]
        local open_condition_id = jump_item.open_condition_id or 0
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id)
        if open_flag == true then
            static_rootControl:closeAllViewPop()
            QuickOpenFuncUtil:openFunc(go_type)
        else
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
        end
    elseif msg == "jump_operate" then
        QuickOpenFuncUtil:openFunc(10024)
        self:closeView()
    elseif msg == "refreshUI" then
        self.m_view:refreshUI()
    elseif msg == "treasure_activate" then
        self:activateTreasure(data)
    elseif msg == "get_receive" then
        self:getTreasureReceive(data)
    elseif msg == "update_quest" then
        self.m_model.m_hero_train_data.quests = data
        self.m_view:refreshUI()
    elseif msg == "exchange" then
        self:activateExchange(data)
    elseif msg == "month_exchange" then
        self:activateMonthExchange(data)
    elseif msg == "eat_exchange" then
        self:activateEatExchange(data)
    elseif msg == "card_exchange" then
        self:activateCardExchange(data)
    elseif msg == "updateNewNet" then
        self:RefreshTagData()
    elseif msg == "get_limit_exchange_btn" then
        self:openView("GiftBag.GifLimitExchangeTaskPop", data)
    elseif msg == "active_month" then
        if data == 1 then
            self:activeWeekCard()
        else
            self:activeMonthCard()
        end
    elseif msg == "item_click" then
        self:openView("Pops.PlayerInfo", {uid = data.uid})
    elseif msg == "btn_wishingBtn" then
        self:getReceivedWish(data)
    elseif msg == "btn_playLanternBtn" then
        self:getWishBlessing(data)
    elseif msg == "btn_receiveBtn" then
        self:getRebate(data)
    elseif msg == "get_more_btn" then --天赐祈福获取更到
        self:openView("GiftBag.HeavenBlessRewardTaskPanel", { draw_data = self.m_model.m_heavenBless_data })
    elseif msg == "refresh_TabLoopScroll" then
        self.m_view:createLoopScroll()
    elseif msg == "heaven_hint_btn" then
        local title  = Language:getTextByKey("gf_str_0143")
        self:openView("Pops.CommonHelpPop", { title = title, content = "tid#WeekendEvent_1" })
    end
end

-- tab按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index)
        self.m_view:refreshUI()
    end
end

--- 重新请求当前页签数据刷新界面
function M:refreshCurView()
    self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
end

function M:buyForSDK(id)
end

--限时兑换兑换奖励
function M:activateExchange(data)
    local function callback(response)
        if response then
            self:netCheckEndTips(response)
            if response["end"] == 1 then
                return
            end
            table.merge(self.m_model.m_exchange_data, response)
            RewardUtil:rewardTipsByData(response.reward)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.gift_id = data.id
    params.version = data.version
    self.m_model:getNetData("exchange", params, callback, nil, true)
end


--满月兑换兑换奖励
function M:activateMonthExchange(data)
    local function callback(response)
        if response then
            self:netCheckEndTips(response)
            if response["end"] == 1 then
                return
            end
            table.merge(self.m_model.m_month_exchange_data, response)
            RewardUtil:rewardTipsByData(response.reward)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.gift_id = data.id
    params.version = data.version
    self.m_model:getNetData("month_exchange", params, callback, nil, true)
end

--满月兑换兑换奖励
function M:activateEatExchange(data)
    local function callback(response)
        if response then
            self:netCheckEndTips(response)
            if response["end"] == 1 then
                return
            end
            table.merge(self.m_model.m_eat_exchange_data, response)
            RewardUtil:rewardTipsByData(response.reward)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.gift_id = data.id
    params.version = data.version
    params.times = data.times
    self.m_model:getNetData("active_exchange", params, callback, nil, true)
end

--英雄兑换兑换奖励
function M:activateCardExchange(data)
    local function callback(response)
        if response then
            self:netCheckEndTips(response)
            if response["end"] == 1 then
                return
            end
            table.merge(self.m_model.m_hero_exchange_data, response)
            RewardUtil:rewardTipsByData(response.reward)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.gift_id = data.id
    params.version = data.version
    params.times = data.times
    self.m_model:getNetData("card_exchange", params, callback, nil, true)
end


--激活藏宝图
function M:activateTreasure(data)
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        if response.update == 1 then
            table.merge(self.m_model.m_treasure_data, response)
        end
        self.m_model:updateTreasureQuests(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data.id
    params.version = data.version
    self.m_model:getNetData("treasure_activate", params, callback, nil, true)
end

--领取藏宝图积分
function M:getTreasureReceive(data)
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        table.merge(self.m_model.m_treasure_data, response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data.id
    params.version = data.version
    self.m_model:getNetData("treasure_receive", params, callback)
end

function M:getDrawRandomDraw(data)
    local consume_data = self.m_model:getDrawConsume()
    if consume_data.data_num > consume_data.user_num then
        local params = {
            text = Language:getTextByKey("new_str_0700"),
            tow_close_btn = true,
            on_ok_call = function ()
                self:updateMsg("get_text")
            end
        }
        self:openView("Pops.CommonPop", params)
        return
    end
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        audio:SendEvtUI("UI_ChouQian_Fx")
        table.merge(self.m_model.m_draw_data, response)
        local function playQianAnimOver()
            RewardUtil:rewardTipsByData(response.reward)
            self.m_view:refreshUI()
        end
        if self.m_view.m_cur_tab_node and response.config_id then
            self.m_view:lockTouch()
            self:setOnceTimer(3.65, function ()
                self.m_view:unlockTouch()
            end)
            self.m_view.m_cur_tab_node:playSpine(response.config_id, playQianAnimOver)
        else
            playQianAnimOver()    
        end
    end
    local params = {}
    params.vsn = self.m_model.m_draw_data.version
    self.m_model:getNetData("draw_random_draw", params, callback)
end

--7日登录领奖
function M:getSeven_Tour(data)
    local function callback(response)
        if response then
            if data.version == 1 and data.day == 2 or data.day == 7 then
                GameUtil:openAppRating() -- appStore评价
            elseif data.version == 2 and data.day == 7 then
                GameUtil:openAppRating() -- appStore评价
            end
            self:netCheckEndTips(response)
            if response["end"] == 1 then
                if response.reward then
                    RewardUtil:rewardTipsByData(response.reward)
                end
                self:openAppRating(data)
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            if response.actives and response.actives[1].id ~= self.m_model.m_seven_tour_data.actives[1].id then
                self.m_model:replaceActives(data.version)
                self:RefreshTagData()
                self:openAppRating(data)
                return
            end
            table.merge(self.m_model.m_seven_tour_data, response)
            self.m_view:refreshUI()
            self:openAppRating(data)
        end
    end
    local params = {}
    params.day = data.day 
    params.version = data.version
    if data.item_index then
        -- 服务器从0开始
        params.item_index = (data.item_index - 1)
    end
    self.m_model:getNetData("active_receive_seven_tour", params, callback)
end

function M:openAppRating(data)
    if data.version == 1 and data.day == 2 or data.day == 7 then
        GameUtil:openAppRating() -- appStore评价
    elseif data.version == 2 and data.day == 7 then
        GameUtil:openAppRating() -- appStore评价
    end
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

--绿林
function M:requestReceive(data)
    local function receivetCallback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.hero_gather_received, response.hero_gather_received)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data
    self.m_model:getNetData("active_receive_hero_gather", params, receivetCallback)
end

--侠客
function M:requestActiveReceive(data)
    local function receivetCallback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.hero_gather_active_received, response.hero_gather_active)
        self.m_view:refreshUI()
    end
    local params = {}
    params.vsn = data.version
    params.reward_id = data.id
    self.m_model:getNetData("active_receive_hero_gather_active", params, receivetCallback)
end

--领取皇家犒赏令
function M:getRoyalReward(data)
    local function receivetCallback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.m_war_older_data, response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data
    self.m_model:getNetData("receive_royal_reward", params, receivetCallback)
end

--领取勇者犒赏令
function M:getHeroicReward(data)
    local function receivetCallback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.m_war_older_data, response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.reward_id = data
    self.m_model:getNetData("receive_warrior_reward", params, receivetCallback)
end

--领取侠客岛令
function M:getGoalCommonReward(data)
    local function receivetCallback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        RewardUtil:rewardTipsByData(response.reward)
        table.merge(self.m_model.m_war_older_data, response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("receive_goal_common_reward", data, receivetCallback)
end
--周卡激活
function M:activeWeekCard()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_month_card_data.week_card, response.week_card)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("open_week_card", nil, receivetCallback)
end

--月卡激活
function M:activeMonthCard()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_month_card_data.month_card, response.month_card)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("open_month_card", nil, receivetCallback)
end

function M:refreshUI()
    self.m_view:refreshUI()
end

function M:getDrawBuy()
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        table.merge(self.m_model.m_draw_data, response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("draw_buy", nil, callback)
end

function M:getWishBlessing(data)
    self.m_model:getNetData("wish_blessing", data, function(response)
        if response then
            if response["end"] == 1 then
                GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self.m_view:refreshActiveEndUI()
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            table.merge(self.m_model.m_kongMingLight_Data, response)
            self:refreshUI()
            if self.m_view.m_cur_tab_node then
                self.m_view.m_cur_tab_node:playKongMingLight()
            end        
        end
    end, nil, nil, nil)
end

function M:getReceivedWish(data)
    self.m_model:getNetData("received_wish", data, function(response)
        if response then
            if response["end"] == 1 then
                GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self.m_view:refreshActiveEndUI()
                return
            end
            RewardUtil:rewardTipsByData(response.reward)
            table.merge(self.m_model.m_kongMingLight_Data, response)
            self:refreshUI()
        end
    end, nil, nil, nil)
end

function M:openScroll(data)
    local comsume_data = self.m_model:getScrollConsume()
    if comsume_data == nil then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        return
    end
    local scroll_cfg = self.m_model:getScrollCfg()
    if self.m_model.m_scroll_data.times >=  scroll_cfg.free_time  then
        if comsume_data.data_num > comsume_data.user_num then
            local params = {
                text = Language:getTextByKey("new_str_0700"),
                tow_close_btn = true,
                on_ok_call = function ()
                    self:updateMsg("get_ace_pag_btn")
                end
            }
            self:openView("Pops.CommonPop", params)
            return
        end
    end
    local function callback(response)
        if response then
            self:netCheckEndTips(response)
            if response["end"] == 1 then
                return
            end
            if  response.is_big_prize ~= 0 then
                local big_reward_cfg = self.m_model:checkBigRcvd()
                RewardUtil:rewardTipsByRewards(big_reward_cfg.reward)
            else
                if response.reward then
                    RewardUtil:rewardTipsByData(response.reward)
                end
            end
            if self.m_model:get_check_scroll_first() == true then
                self.m_model:set_scroll_first()
            end
            table.merge(self.m_model.m_scroll_data, response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.position = data.position
    params.vsn = data.vsn
    self.m_model:getNetData("open_scroll", params, callback, nil)
end

--region 充值返利
function M:getRebate(params)
    local function callback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model.m_rechargeRebata_Data.quests = response.quests
            self:refreshUI()
        end
    end
    self.m_model:getNetData("common_quest_recv_task",params ,callback)
end
--endregion 


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
    if next(self.m_model.tag_table) == nil then
        self:updateMsg(99999)
    end 
end

--统一刷新数据
function M:RefreshTagData()
    self.m_model:refreshData(function ()
        self.m_view:refreshActiveEndUI()
        self.m_model.is_refresh_bl = false
        if next(self.m_model.tag_table) == nil then
            self:updateMsg(99999)
        end 
    end)
end

function M:updateTime()
    self.m_view:updateTime()
    if self.m_model.is_refresh_bl == false and self.m_model.m_refresh_time > 0 and UserDataManager:getServerTime() > self.m_model.m_refresh_time then
        self:updateMsg("updateNewNet")
        self.m_model.is_refresh_bl = true
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
