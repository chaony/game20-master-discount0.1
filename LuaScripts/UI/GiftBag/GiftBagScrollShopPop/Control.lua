local M = class("GiftBagScrollShopPopControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1,handler(self,self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_is_token == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
		self:closeView()
    elseif msg == "buy" then
        self:buyForSDK(data)
    end
end

--调用sdk充值
function M:buyForSDK(charge_id)
    if self.m_model.m_is_token == true then
        self:buyUseVoucher(charge_id, function ()
            self:getNetUrl()
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
            self:getNetUrl()
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

function M:getNetUrl()
    local function callback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("activity_gift_index", nil, callback)
end

function M:updateTime()
    
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M;