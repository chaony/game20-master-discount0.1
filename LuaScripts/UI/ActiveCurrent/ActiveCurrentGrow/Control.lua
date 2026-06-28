local M = class("ActiveCurrentGrowControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:updateMsg("refreshRedPoint", "no_request", "ActiveCurrent.ActiveCurrentMain")
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        end
        self:closeView()
    elseif msg == "buy" then
        self:buyForSDK(data)
    elseif msg == "get_hero_gift" then
        self:getHeroGiftReward(data)
    elseif msg == "buy_sdk_update" then
        self:refreshIndex()
    elseif msg == "refreshUI" then
        self.m_view:refreshUI()
    elseif msg == "time_down" then
        self:closeAct()
    elseif msg == "ranking_btn" then
        self:openView("ActiveCurrent.ActiveCurrentRankListPop", {vsn = self.m_model.m_version, open_type = "grow"})
    elseif msg == "reward_btn" then
        self:openView("ActiveCurrent.ActiveCurrentDailyReward", { daily_recv_rewards = self.m_model.m_daily_recv_rewards, version = self.m_model.m_version, hero_id = self.m_model.m_hero_skin_data.hero })
    elseif msg == "update_net_data_key" then
        if data and data.key then
            if self.m_model.m_data[data.key] ~= data.value then
                self.m_model.m_data[data.key] = data.value
            end
        end
    elseif msg == "udpate_daily_recv_rewards" then
        if data and data ~= self.m_model.m_daily_recv_rewards then
            self.m_model.m_daily_recv_rewards = data
            self.m_view:refreshUI()
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = Language:getTextByKey("gf_str_0006")
        params.content = "tid#ActiveEventHero1"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:closeAct()
    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1149"), delay_close = 2})
    self:closeView()
end

function M:refreshIndex()
    local function receivetCallback(response)
        self.m_model:updateNetData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("hero_gift_index", nil, receivetCallback)
end

--调用sdk充值
function M:buyForSDK(charge_id)
    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            self:refreshIndex()
        end)
        return
    end
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(2, function ()
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
            self:refreshIndex()
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

--英雄成长礼包-领取免费礼包
function M:getHeroGiftReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        self.m_model:updateNetData(response)
        --table.merge(self.m_model.m_hero_gift_data,response.gifts_detail)
        self.m_view:refreshUI()
    end
    local params = {
        version = data.version,
        gift_id = data.id
    }
    self.m_model:getNetData("receive_hero_gift", params, receivetCallback)
end

--通用成长礼包-领取免费礼包
function M:getCommonGrowUpGiftReward(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_growth_gift_data,response.gifts_detail)
        self.m_view:refreshUI()
    end
    local params = {
        version = data.version,
        gift_id = data.id
    }
    self.m_model:getNetData("receive_growth_gift", params, receivetCallback)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "charge" then
        if data.add_token and data.add_token == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("充值失败！"), delay_close = 2})
            return
        end
        self:refreshIndex()
    end
end

function M:netCheckEndTips(response)
    if response.update == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:closeView()
    end
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:closeView()
    end
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {self, self.dataUpdateEvent})
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
