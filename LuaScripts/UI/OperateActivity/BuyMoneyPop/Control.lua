local M = class("BuyMoneyPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "big_close_btn" then -- 关闭
        self:closeView()
    elseif msg == "buy_btn" then
        self:buyForSDK()
    end
end

--调用sdk充值
function M:buyForSDK()
    local charge = ConfigManager:getCfgByName("charge")
    local charge_cfg = self.m_model:getWarCfg()
    self:buyForSDK(charge_cfg.charge_id,function ()
        self:closeView()
        self:updateMsg("buy_sdk_update", nil, "OperateActivity")
    end)
end

function M:buyForSDK(charge_id, callback)
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        if callback then
            callback()
        end
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(8, function ()
        self.m_view:unlockTouch()
        if callback then
            callback()
        end
        self.timer_id = nil
    end)
    PayUtil:rechargeByChargeId(charge_id, function ()
        if self.m_view then
            self.m_view:unlockTouch()
            if callback then
                callback()
            end
            if self.timer_id then
                self:removeTimer(self.timer_id)
                self.timer_id = nil
            end
        end
    end)
end

return M
