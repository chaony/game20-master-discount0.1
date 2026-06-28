local M = class("FineClothesControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id_count_down = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "btn_close" then    -- 返回
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
        if self.m_model:getTokenFlag() == true then
            self:updateMsg("refresh_data", nil, "TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "page_update" then
        audio:SendEvtUI("UI_Tab_N1")
        self.m_model:setCurrentPage(data)
        self.m_view:refreshToggleStatus()
    elseif msg == "btn_get_1" or msg == "btn_get_2" then
        audio:SendEvtUI("UI_Tab_N1")
        local charge_id_cur = self.m_model:getCurrentGiftChargeID()
        local id_cur = self.m_model:getCurrentGiftID()
        local pos_cur = self.m_model:getCurrentPos()
        if self.m_model:checkGiftTimesLimited(pos_cur, id_cur) == false then
            self:buyForSDK(charge_id_cur)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fine_clothes_006"), delay_close = 2})
        end
    end
end

--调用sdk充值
function M:buyForSDK(charge_id)
    if charge_id == nil or charge_id == 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fine_clothes_007", charge_id or 0), delay_close = 2})
        return
    end

    audio:SendEvtUI("UI_Pay")
    if self.m_model:getTokenFlag() == true then
        self:buyUseVoucher(charge_id, function ()
            self:refreshData()
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
            self:refreshData()
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

--整体刷新
function M:refreshData()
    local function netCallback(response)
        if response.update then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:closeView()
            return
        end
        if response["end"] then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:closeView()
            return
        end
        self.m_model:updateData(response)
        self.m_view:refreshRewardStatus()
    end
    self.m_model:getNetData("active_common_gift_index", {open_id = self.m_model:getOpenID(), vsn = self.m_model:getVersion()}, netCallback)
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id_count_down)
    M.super.destroy(self)
end

return M
