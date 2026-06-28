local M = class("ActiveCurrentGiftControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint", nil, "ActiveCurrent.ActiveCurrentMain")
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
    elseif msg == "buy_btn" or msg == "buy_btn_2" or msg == "buy_btn_3" or msg == "buy_btn_4" then
        local curTime = self.m_model.m_end_ts - UserDataManager:getServerTime()
        if curTime <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end
        local data_index = data.index
        self:buyForSDK(data)
    elseif msg == "look_hero_info" then
        self:showHeroInfo()
    elseif msg == "help_btn" then
        local info_data = self.m_model:BasicInfo() --获取配置
        local params = {}
        params.title = info_data.name
        params.content = info_data.des
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refresh_index" then
        self:updateGiftData(function ()
            self.m_view:updateBagNode()
        end)
    elseif msg == "buy_hero_btn" then
        local charge_id = self.m_model:getHeroPriceCfg("charge_id")
        if charge_id then
            self:buyForSDKByChargeId(charge_id)
        else
            Logger.logError("charge_id is nil,", "get charge_id from hero_event_hero failed")
        end
    end
end

--刷新数据
function M:refreshData()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return
        end
        self.m_model.m_hero_gift_times = response.hero_gift_times or 0
        local params = {key = "hero_gift_times", value = self.m_model.m_hero_gift_times}
        self:updateMsg("update_net_data_key", params, "ActiveCurrent.ActiveCurrentMain")
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("hero_event_index",{version = self.m_model.m_version }, netCallback)
end

--调用sdk充值
function M:buyForSDKByChargeId(charge_id)
    if self.m_model.is_tokens == true then
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
            self:refreshData()
        end
    end)
end

--调用sdk充值
function M:buyForSDK(data)
    if data then
        --免费
        if data.cell_data.cfg.price == 0 then
            local function netCallback(response)
                if response then
                    self.m_model:updateGiftDataFree(response.gift_data)
                    self.m_view:updateBagNode()
                    RewardUtil:rewardTipsByData(response.reward) --展示奖励
                end
            end
            local params = {}
            params.version = self.m_model:getVersion()
            params.gift_id = data.cell_data.id
            params.place_id = data.cell_data.cfg.place
            self.m_model:getNetData("hero_event_receive_free_gift", params, netCallback)
        --付费    
        elseif data.cell_data.cfg.charge_id then
            self.m_view:lockTouch()
            --代金券
            if self.m_model.is_tokens == true then
                self:buyUseVoucher(data.cell_data.cfg.charge_id, function ()
                    self.m_model:updateGiftData(function () self.m_view:updateBagNode() end)
                    self.m_view:unlockTouch()
                end)
            --常规购买      
            else
                PayUtil:rechargeByChargeId(data.cell_data.cfg.charge_id, function ()
                    if self.m_model and self.m_view then
                        self.m_model:updateGiftData(function ()
                            if self.m_view then
                                self.m_view:updateBagNode()
                            end
                        end)
                        self.m_view:unlockTouch()
                    end
                end)
            end
            local function callback()
                self.m_view:unlockTouch()
            end
            self:setOnceTimer(1.0, callback)
        end
    end
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

function M:showHeroInfo()
    self:closeView("Pops.HeroLookInfo",nil, false)
    self:openView("Pops.HeroLookInfo", {hero_id = self.m_model.m_hero_skin_data.hero, is_new = false})
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
