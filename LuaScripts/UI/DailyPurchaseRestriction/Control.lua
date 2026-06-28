local M = class("DailyPurchaseRestrictionControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
        self:updateMsg("common_refresh", nil, "parent")
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data", nil, "TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
    elseif msg == "PurchaseBtn" then
        self:onPurchaseBtn()
    end
end

function M:onPurchaseBtn()
    local data = self.m_model:getGiftCfg() or {}
    local charge_id = data.charge_id
    if not charge_id then
        return
    end
    if charge_id == nil or charge_id == 0 then
        Logger.log("无效的charge_id")
        return
    end
    if self.timer_pay then
        Logger.logWarningAlways(self.timer_pay, "-------------IsPay-----------")
        return
    end
    self.m_view:lockTouch()
    self.timer_pay = self:setOnceTimer(2, function ()
        self.m_view:unlockTouch()
        self.timer_pay = nil
    end)

    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            if self.m_view then
                self.m_view:unlockTouch()
                if self.timer_pay then
                    self:removeTimer(self.timer_pay)
                    self.timer_pay = nil
                end
                self:updateMsg("common_refresh", nil, "parent")
                self:updateMsg(99999, nil, "TopUpGiftBag.ToKensSelectGiftBagPop")
                self:closeView()
            end
        end)
    else
        PayUtil:rechargeByChargeId(charge_id, function ()
            if self.m_view then
                self.m_view:unlockTouch()
                if self.timer_pay then
                    self:removeTimer(self.timer_pay)
                    self.timer_pay = nil
                end
                self:updateMsg("common_refresh", nil, "parent")
                self:closeView()
            end
        end)
    end
end

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

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
