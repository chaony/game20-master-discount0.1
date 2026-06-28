local M = class("LimitedHeroControl", LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_FirstPay")
    self:updateTime()
    self.m_timer_id_count_down = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refresh_data", nil, "TopUpGiftBag.ToKensSelectGiftBagPop")
        self:closeView()
    elseif msg == "charge_btn1" then 
        self:changeToTag(1)
    elseif msg == "charge_btn2" then
        self:changeToTag(2)
    elseif msg == "charge_btn3" then
        self:changeToTag(3)
    elseif msg == "charge_btn4" then
        self:changeToTag(4)
    elseif msg == "day_btn_1" then
        self:changeToDay(1)
    elseif msg == "day_btn_2" then
        self:changeToDay(2)
    elseif msg == "day_btn_3" then
        self:changeToDay(3)
    elseif msg == "buy_btn" then
        local selected_tag_index = self.m_model:getSelectedTagIndex()
        local main_data_tag = self.m_model:getMainData(selected_tag_index)
        if main_data_tag then
            self:buy(main_data_tag.cfg.charge_id)
        end
    elseif msg == "get_reward_btn" then
        local selected_tag_index = self.m_model:getSelectedTagIndex()
        local selected_day_index = self.m_model:getSelectedDayIndex()
        if data and data.is_auto_receive == true then --购买后自动领取第一天奖励
            selected_day_index = 1
        end
        local main_data_tag = self.m_model:getMainData(selected_tag_index)
        local status = main_data_tag.status_data.can_receive["day_" .. selected_day_index]
        if status == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("limited_hero_003"), delay_close = 2})
            return
        elseif status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("limited_hero_005"), delay_close = 2})
            return
        end
        if main_data_tag then
            self:getReward(main_data_tag.cfg.charge_id, selected_day_index)
        end
    end
end

function M:changeToTag(tag_index)
    if self.m_model:getSelectedTagIndex() == tag_index then
        return
    end
    self.m_model:setSelectedTagIndex(tag_index)
    self.m_model:setSelectedDayIndex(1)
    self.m_view:updateTagInfo()
end

function M:changeToDay(day_index)
    if self.m_model:getSelectedDayIndex() == day_index then
        return
    end
    self.m_model:setSelectedDayIndex(day_index)
    self.m_view:updateDayInfo()
end

--领取奖励
function M:getReward(charge_id, day_index)
    if self:lockView() == false then --unlockview in refreshData
        return
    end
    local function receivetCallback(response)
        if self:responseCheck(response) == false then
            self:closeView()
            return
        end
        self:refreshData()
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {}
    params.vsn = self.m_model:getVersion()
    params.charge_id = charge_id
    params.day = day_index
    self.m_model:getNetData("limit_hero_receive", params, receivetCallback)
end

--购买
function M:buy(charge_id)
    if charge_id == nil or charge_id == 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_038", charge_id or 0), delay_close = 2})
        return
    end

    audio:SendEvtUI("UI_Pay")

    if self:lockView() == false then --unlockview in refreshData
        return
    end

    if self.m_model:getTokenFlag() == true then
        self:buyUseVoucher(charge_id)
        return
    end

    PayUtil:rechargeByChargeId(charge_id, function()
        self:refreshData(function()
            self:updateMsg("get_reward_btn", {is_auto_receive = true}) --购买后自动领取第一天奖励
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
        self:refreshData(function()
            self:updateMsg("get_reward_btn", {is_auto_receive = true}) --购买后自动领取第一天奖励
        end)
    end
    local params = {
        charge_id = data
    }
    self.m_model:getNetData("voucher", params, receivetCallback)
end

--整体刷新
function M:refreshData(callback)
    local function netCallback(response)
        if self:responseCheck(response) == false then
            self:closeView()
            return
        end
        self.m_model:updateMainData(response)
        self.m_view:refreshUI()
        self:unlockView()
        if callback then
            callback()
        end
    end
    self.m_model:getNetData("limit_hero_index", nil, netCallback)
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

--锁屏
function M:lockView()
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        return false
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(5, function ()
        self.m_view:unlockTouch()
        self.timer_id = nil
    end)
    return true
end

function M:unlockView()
    if self.timer_id then
        self.m_view:unlockTouch()
        self:removeTimer(self.timer_id)
        self.timer_id = nil
    end
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:unlockView()
    self:removeTimer(self.m_timer_id_count_down)
    M.super.destroy(self)
end

return M
