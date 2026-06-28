local M = class("TopUpShopPopControl", LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_GoldShop")
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "buy" then
        self:buyForSDK(data)
    end
end

--调用sdk充值
function M:buyForSDK(data)
    if self.m_model.is_tokens == true then
        self:buyUseVoucher(data, function ()
            self:updateMsg("refreshUI", nil, "TopUpGiftBag")
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
    PayUtil:rechargeByChargeId(data, function (payResult)
        self.m_view:unlockTouch()
        if self.timer_id then
            self:removeTimer(self.timer_id)
            self.timer_id = nil
        end
        if payResult.code == "success" and payResult.goodsId and payResult.goodsId ~= "" then
            local sound_id = self.m_model:getChargeSuccSoundId(payResult.goodsId)
            audio:SendEvtUI(sound_id)
        end
        self:updateMsg("refreshUI", nil, "TopUpGiftBag")
        self:updateMsg("buy_sdk_update", nil, "GiftBag.FirstCharge")
        self:getNetUrl()
    end)
end

function M:getNetUrl()
    local function callback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("pay_shop_index", nil, callback)
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

return M
