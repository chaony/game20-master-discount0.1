local M = class("SpecialOfferPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        self:closeView()
        self:updateMsg("refreshRecommendNode","TopUpGiftBag.RecommendNode")
    elseif msg == "get_reward_btn" then
        if data.charge_id == 0 then
            self:getGiftOff(data.id)
        else
            self:buyForSDK(data.charge_id)
        end
    elseif msg == "one_key_btn" then
        if self.m_model.pack_cfg then
            self:buyForSDK(self.m_model.pack_cfg.charge_id)
        end
    end
end

--领取特惠礼包
function M:getGiftOff(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model.m_gift_off_data = response.gift_off
        self.m_model.m_actives= response.actives
        self.m_view:refreshUI()
        self:updateMsg("buy_sdk_update", nil, "TopUpGiftBag")
        self:updateMsg("refreshUI", nil, "TopUpGiftBag")
    end
    local params = {}
    params.reward_id = data
    self.m_model:getNetData("receive_gift_off", params, receivetCallback)
end

--调用sdk充值
function M:buyForSDK(charge_id)
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
        if self.m_model then
            self.m_view:unlockTouch()
            local function callback(response)
                if self.m_model then
                    self.m_model.m_gift_off_data = response.gift_off
                    self.m_model.m_actives= response.actives
                end
                if self.m_view then
                    self.m_view:refreshUI()
                end
                self:updateMsg("buy_sdk_update", nil, "TopUpGiftBag")
            end
            self.m_model:getNetData("gift_off_index", nil, callback)
        end
    end)
end

return M
