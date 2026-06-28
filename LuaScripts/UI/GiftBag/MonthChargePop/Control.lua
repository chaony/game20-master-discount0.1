local M = class("MonthChargePopControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_data", nil, "TopUpGiftBag.ToKensSelectGiftBagPop")
        self:updateMsg("common_refresh" ,nil , "parent")
        self:closeView()
    elseif msg == "help_btn" then
        self:showHelpPop()
    elseif msg == "buy_btn" then
        self:buyForSDK(data)
    end
end

-- 调用 SDK 充值
function M:buyForSDK(data)
    local charge_id = data.cell_data.cfg.charge_id
    if charge_id == nil or charge_id == 0 then
        local params = {}
        params.delay_close = 2
        params.msg = Language:getTextByKey("gu_jian_qi_tan_str_038", charge_id or 0)
        GameUtil:lookInfoTips(self, params)
        return
    end
    audio:SendEvtUI("UI_Pay")
    if self.m_model:isToken() then
        self:buyUseVoucher(charge_id, handler(self, self.refreshData))
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

-- 使用代金券购买礼包
function M:buyUseVoucher(data, callback)
    local function receiveCallback(response)
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
    self.m_model:getNetData("voucher", {charge_id = data}, receiveCallback)
end

-- 规则弹窗
function M:showHelpPop()
    local params = {}
    params.title = "month_charge_text_0001"
    params.content = self.m_model:getHelpDes()
    self:openView("Pops.CommonHelpPop", params)
end

-- 刷新整体数据
function M:refreshData()
    local function netCallback(response) 
        self.m_model:refreshGiftBagData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("wl_relics_index", {}, netCallback)
end

-- 活动时间计时器
function M:updateTime()
    local end_ts = self.m_model:getEndTs()
    local left_ts = end_ts - UserDataManager:getServerTime()
    if left_ts > 0 then
        self.m_view:updateActivityTimer(left_ts)
    else
        self.m_view:updateActivityTimer(0)
        self:closeView()
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
