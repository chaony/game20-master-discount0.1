local M = class("commonGiftTwoControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
            self.m_model.m_callback()
        end
        if self.m_model.m_params.refresh_name then
            self:updateMsg("refresh_data",nil,self.m_model.m_params.refresh_name)
        end
        self:closeView()
        --toggle切换
    elseif msg == "buy_gift" then
        if data == nil then
            return
        end
        audio:SendEvtUI("Ui_Reward")
        local cell_data = data
        local sort = cell_data.cfg.price_type or 1
        if cell_data.status_paper == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_045"), delay_close = 2})
            return
        end
        if sort == 1 then -- 元宝
            self:getFreeGift(data)
        elseif sort == 2 then -- 花钱购买
            self:buyGift(data)
        else
            Logger.logError(sort, "ship_gift sort is error ")
        end
    elseif msg == "buy_skip_btn" then
        audio:SendEvtUI("UI_Tab_N1")
        if self.m_model:checkHeroSkinTimesLimited() == false then
            local hero_skin_cfg = self.m_model:getHeroSkinCfg()
            self:buyForSDK(hero_skin_cfg.charge_id)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_039"), delay_close = 2})
        end
        --英雄皮肤展示
    elseif msg == "btn_heroSkinBtn" then
        self:showHeroInfo()
        --帮助说明
    elseif msg == "help_btn" then
        audio:SendEvtUI("UI_Popup_N1")
        local params = {}
        params.title = "raccon_text_0005"
        local content = self.m_model:getMainCfgVByK("raccoon_des") or "tid#XiaoHuanXiongDes_1"
        params.content = content
        self:openView("Pops.CommonHelpPop", params)
    --elseif msg == "box_click" then
    --    audio:SendEvtUI("UI_Pay")
    --    local rewards = data.data.rewards or {}
    --    self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.status == -1})
    elseif msg == "look_hero_info" then
        local reward = self.m_model:getHeroSkinCfg()
        local reward_data = RewardUtil:getProcessRewardData(reward.reward[1])
        if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
            static_rootControl:openView("Pops.HeroLookInfo", {hero_id = reward_data.data_id})
        elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
            static_rootControl:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = reward_data.data_id})
        end
    end
end

--购买礼包
function M:buyGift(data)
    if data.status_paper == 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_033"), delay_close = 2})
        return
    end
    if data.cfg.price == 0 then
        self:getFreeGift(data)
    else
        self:buyForSDK(data.cfg.charge_id)
    end
end

--免费礼包
function M:getFreeGift(data)
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
            self.m_model:initTotalData(response)
            --self.m_model:updateGiftData(response)
            self.m_view:refreshUI()
            --self.m_view:updateLoopScroll()
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local params = {}
    params.open_id = self.m_model:getOpenID()
    params.vsn = self.m_model:getVersion()
    params.paper_id = data.paper_index
    params.place = data.place_index
    self.m_model:getNetData("active_common_gift_buy", params, receivetCallback)
end

--调用sdk充值
function M:buyForSDK(charge_id)
    if charge_id == nil or charge_id == 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_038", charge_id or 0), delay_close = 2})
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

--英雄皮肤展示
function M:showHeroInfo()
    local hero_skin_cfg = self.m_model:getHeroSkinCfg()
    local reward_data = RewardUtil:getProcessRewardData(hero_skin_cfg.reward[1])
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        self:openView("Pops.HeroLookInfo", {hero_id = reward_data.data_id, is_new = false})
    elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
        self:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = reward_data.data_id})
    end
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
        self.m_model:initTotalData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("active_common_gift_index", {open_id = self.m_model:getOpenID(), vsn = self.m_model:getVersion()}, netCallback)
end


--计时器
function M:updateTime()
    --self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M;
