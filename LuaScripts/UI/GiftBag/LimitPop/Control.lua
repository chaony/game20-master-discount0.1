local M = class("LimitPopControl", LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
    if self.m_model.m_tag_table then
        if next(self.m_model.m_tag_table) == nil then
            self:updateMsg(99999)
        end
    end
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "active_close_btn" then -- 关闭
        for k,v in pairs(self.m_model.m_tag_table) do
            local end_ts = self.m_model:getGiftPushById(v.id)
            if end_ts > 0 then
                UserDataManager.local_data:setUserDataByKey("push_gift_" .. v.id.."_"..end_ts, 1)
            end
        end
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_data_callback)
        end
        if self.m_model.m_is_token == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        end
        self:closeView()
    elseif msg == "get_reward" or msg == "get_reward_active" then   
        self:buyForSDK(self.m_model.m_gift_cfg.charge_id)
    elseif msg == "change_tag" then   
         self.m_model.m_select_index = data
         self.m_model:updateSelectData()
         self.m_view:createLoopScroll()
         self.m_view:refreshUI()
         --self.m_view:setSpine()
    end
end

--调用sdk充值
function M:buyForSDK(charge_id)
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        return
    end
    if self.m_model.m_is_token == true then
        self:buyUseVoucher(charge_id, function ()
            if self.m_view then
                self.m_view:refreshUI()
            end
            if callback then
                callback()
            end
        end)
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
            self.m_model:getNetData("user_heartbeat", nil, nil, 0)
        end
        if self.m_view then -- GPM issue_id: 58c88c65cb81789bced3678fe1fca8da
            self.m_view:unlockTouch()
        end
        self:updateMsg(99999)
        self:updateMsg("common_refresh", nil, "parent")
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
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg(99999)
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
function M:UpdateTime(_, dt)
    self.m_view:updateTime()
end

return M
