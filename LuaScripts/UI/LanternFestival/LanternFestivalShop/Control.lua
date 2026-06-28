local M = class("LanternFestivalShopControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "refresh_data" then
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
            self:updateMsg("refresh_data", response, "LanternFestival")
            self.m_model:initData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("active_lantern_index", nil, netCallback)
    elseif msg == "get_free_ladder_gift" then --免费阶梯礼包
        self:getFreeLadderGift(data)
    elseif msg == "help_btn" then
        local lan_cfg = self.m_model:get_lantern_festival()
        local params = {}
        params.title = "lantern_festival_text_0005"
        params.content = lan_cfg.des
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "buy" then
        self:buyForSDK(data)
    elseif msg == "buy_skip_btn" then
        if self.m_model:getClothesGift() == true then
            self:buyForSDK(self.m_model.m_clothes_cfg.charge_id)
        end
    elseif msg == "btn_heroSkinBtn" then
        self:showHeroInfo()
    end
end

function M:destroy()
    M.super.destroy(self)
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


--调用sdk充值
function M:buyForSDK(charge_id)
    audio:SendEvtUI("UI_Pay")
    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            self:RefreshOneTagData()
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
            self:RefreshOneTagData()
        end
    end)
end

--免费阶梯礼包
function M:getFreeLadderGift(data)
    local function receivetCallback(response)
        if response then
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
            self:updateMsg("refresh_data", response, "LanternFestival")
            table.merge(self.m_model.m_gifts_data, response)
            RewardUtil:rewardTipsByData(response.reward)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.vsn = data.vsn
    params.place = data.id
    params.open_id = data.open_id
    self.m_model:getNetData("gift_value_daily_recv", params, receivetCallback)
end

function M:showHeroInfo()
    local reward_data = RewardUtil:getProcessRewardData(self.m_model.m_clothes_cfg.reward[1])
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        self:openView("Pops.HeroLookInfo", {hero_id = reward_data.data_id, is_new = false})
    elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
        self:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = reward_data.data_id})
    end
end

--付费后的整体刷新
function M:RefreshOneTagData()
    self:updateMsg("refresh_data")
end


--计时器
function M:UpdateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M;
