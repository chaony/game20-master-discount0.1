local M = class("WindAndCloudCoupleControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point", nil, "WindAndCloud.WindAndCloudMain")
        self:closeView()
    elseif msg == "explain_btn" then
        local title_name = ""
        if self.m_model.active_data then
            title_name = self.m_model.active_data.name
        end
        self:openView("Pops.CommonHelpPop", {title = title_name, content = "tid#ValentineFestival_2"})
    --购买战令
    elseif msg == "gift_buy_btn" then
        local war_order_data = self.m_model:getWarOrderData()
        if war_order_data then
            self:buy(war_order_data.charge_id)
        end
    --领取奖励
    elseif msg == "get_reward" then
        self:requestReceiveWarriorReward(data)
    end
end

--领取奖励
function M:requestReceiveWarriorReward(data)
    if data.status_free == 1 or data.status_fee == 1 then
        local function receiveWarriorCallback(response)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward)
        end
        local main_data = self.m_model:getMainData() or {}
        local params = {}
        params.open_id = self.m_model:getOpenID()
        params.vsn = main_data.war_order.cur_version or 1
        params.reward_id = data.id
        self.m_model:getNetData("war_order_receive_common_reward", params, receiveWarriorCallback)
    end
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
    local function netCallbackGift(response)
        if self:responseCheck(response) == false then
            self:closeView()
            return
        end
        self.m_model:updateData(response)
        self.m_view:refreshUI()
        if callback then
            callback()
        end
    end
    local params = {}
    params.open_id = self.m_model:getOpenID()
    params.vsn = self.m_model:getVersion()
    self.m_model:getNetData("war_order_common_war_order_index", params, netCallbackGift)
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
