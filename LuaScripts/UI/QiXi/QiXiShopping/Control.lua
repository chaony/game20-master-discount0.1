local M = class("QiXiShoppingControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point", nil, "QiXi.QiXiMain")
        self:closeView()
    elseif msg == "explain_btn" then
        local active_data = self.m_model:getActiveData() or {}
        self:openView("Pops.CommonHelpPop", {title = active_data.name or "", content = "tid#ValentineFestival_3"})
    elseif msg == "exchange_btn" then
        self:openView("QiXi.QiXiExchange", {is_token = self.m_model:getTokenFlag()})
    elseif msg == "shopping_rank_btn" then
        self:openView("QiXi.QiXiShoppingRank", {version = self.m_model:getVersion()})
    elseif msg == "gift_btn_1" then
        if self.m_model:getTimeLimit() == 1  then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end
        self:showBuyGiftWithCountWindow()
    elseif msg == "gift_btn_2" then
        if self.m_model:getTimeLimit() == 1  then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end
        local gift_data = self.m_model:getGiftData(2)
        if gift_data.status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_047"), delay_close = 2})
            return
        end
        self:buy(gift_data.cfg.charge_id)
    end
end

--领取奖励
function M:getReward(num)
    local function receivetCallback(response)
        if self:responseCheck(response) == false then
            self:closeView()
            return
        end
        self:refreshData()
        RewardUtil:rewardTipsByData(response.reward)
    end
    local gift_data = self.m_model:getGiftData(1)
    local params = {}
    params.open_id = self.m_model:getOpenID()
    params.vsn = self.m_model:getVersion()
    params.paper_id = gift_data.paper_index
    params.place = gift_data.place_index
    params.buy_count = num
    self.m_model:getNetData("active_common_gift_buy", params, receivetCallback)
end

--购买
function M:buy(charge_id)
    if charge_id == nil or charge_id == 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_038", charge_id or 0), delay_close = 2})
        return
    end

    audio:SendEvtUI("UI_Pay")

    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(8, function ()
        self.m_view:unlockTouch()
        self.timer_id = nil
    end)

    if self.m_model:getTokenFlag() == true then
        self:buyUseVoucher(charge_id, function ()
            self:refreshData(function()
                if self.m_view then
                    self.m_view:unlockTouch()
                    if self.timer_id then
                        self:removeTimer(self.timer_id)
                        self.timer_id = nil
                    end
                end
            end)
        end)
        return
    end

    PayUtil:rechargeByChargeId(charge_id, function(response)
        self:refreshData(function()
            if self.m_view then
                self.m_view:unlockTouch()
                if self.timer_id then
                    self:removeTimer(self.timer_id)
                    self.timer_id = nil
                end
            end
        end)
    end)
end

--购买，使用代金券
function M:buyUseVoucher(data, callback)
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
    local function receivetCallback(response)
        if response and response.reward  then
            RewardUtil:rewardTipsByData(response.reward)
        end
        if callback then
            callback()
        end
    end
    local params = {
        charge_id = data
    }
    self.m_model:getNetData("voucher", params, receivetCallback)
end

--整体刷新
function M:refreshData(callback)
    local function netCallbackValentine(response)
        if self:responseCheck(response) == false then
            self:closeView()
            return
        end
        self.m_model:updateParamsData(response)
        
        local function netCallbackGift(response)
            if self:responseCheck(response) == false then
                self:closeView()
                return
            end
            self.m_model:updateGiftData(response)
            self.m_view:updateGiftInfo()
            if callback then
                callback()
            end
        end
        local param = {}
        param.open_id = self.m_model:getOpenID()
        param.vsn = self.m_model:getVersion()
        self.m_model:getNetData("active_common_gift_index", param, netCallbackGift)
    end
    self.m_model:getNetData("valentine_festival_box_index", nil, netCallbackValentine)
end

function M:responseCheck(response)
    if response.update then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        return false
    end
    if response["end"] then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        return false
    end
    return true
end

function M:showBuyGiftWithCountWindow()
    local gift_data = self.m_model:getGiftData(1) or {}
    local params =
    {
        --内容
        msg = Language:getTextByKey("qi_xi_037"),
        --标题
        title = gift_data.cfg.gift_name or "",
        --通知的类名
        className = "QiXi.QiXiShopping",
        --消耗类型
        cost_data = gift_data.cfg.price_type or 1,
        --消耗
        cost = gift_data.cfg.price or 1,
        --点击购买
        clickBuy = function(num)
           self:getReward(num)
        end
    }
    self:openView("QiXi.QiXiShoppingBuyGiftWithCount", params)
end

--计时器
function M:UpdateTime(_, dt)
    dt = dt or 0
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
