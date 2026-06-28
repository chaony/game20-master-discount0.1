local M = class("SecretStoreControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn"  then    -- 返回
        self:updateMsg("common_refresh" ,nil ,"parent")
        self:closeView()
    elseif msg == "attendance_bonus_btn" then
        self:openView("SecretStore.AttendanceBonusPop", params)
    elseif msg == "help_btn" then
        local cfg_Data = ConfigManager:getCfgByName("mystery")
        local content = Language:getTextByKey(cfg_Data[1].des)
        self:openView("Pops.CommonHelpPop", { title = ConfigManager:getCfgByName("open_condition")[363].name, content = content })
    elseif msg == "raffle_btn" then
        self:getDiscount()
    elseif msg == "buy" then
        self:getPayGiftBag(data)
    elseif msg == "off_all_btn" then
        local charge_id = self.m_model.m_pack_data.charge_id
        self:getPayGiftBag(charge_id)
    elseif msg == "get_gift_off" then
        self:getFreeGiftBag(data)
    elseif msg == "updateRed" then
        self:refreshData(data)
    end
end

function M:updateTime()
    self.m_view:updateTime()
    self.m_model:updateTime()
end

--免费
function M:getFreeGiftBag(data)
    local function callback(response)
        if response.reward then
            RewardUtil:rewardTipsByData(response.reward)
            self:refreshData(response)
        end
    end
    self.m_model:getNetData("mystery_shop_receive",data,callback)
end

--付费
function M:getPayGiftBag(charge_id)

    if self.m_model.m_discount == 1 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("secret_store_text16"), delay_close = 2})
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
    self.timer_pay = self:setOnceTimer(8, function ()
        self.m_view:unlockTouch()
        self.timer_pay = nil
    end)
    PayUtil:rechargeByChargeId(charge_id, function ()
        if self.m_view then
            self.m_view:unlockTouch()
            if self.timer_pay then
                self:removeTimer(self.timer_pay)
                self.timer_pay = nil
            end
            self:getAndRefreshData()
        end
    end)
end

function M:refreshData(response)
    self.m_model:updateData(response)
    self.m_view:refreshUI()
end

function M:getAndRefreshData()
    local function callbcak(response)
        self:refreshData(response)
    end
    self.m_model:getNetData("mystery_shop_index",nil,callbcak)
end

--抽取折扣
function M:getDiscount()
    local function callback(response)
        if response then
            self:refreshData(response)
        end
    end
    self.m_model:getNetData("mystery_shop_discount",nil,callback)
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M;
