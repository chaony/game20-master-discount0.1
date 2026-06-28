local M = class("MoonShadowGiftControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPointGift", nil, "MoonShadow.MoonShadowMain")
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
    elseif msg == "buy_btn_1" or msg == "buy_btn_2" or msg == "buy_btn_3" or msg == "buy_btn_4" then
        local curTime = self.m_model.m_end_ts - UserDataManager:getServerTime()
        if curTime <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end
        local data_index = 1
        if msg == "buy_btn_2" then
            data_index = 2
        elseif msg == "buy_btn_3" then
            data_index = 3
        elseif msg == "buy_btn_4" then
            data_index = 4
        end
        self:buyForSDK(self.m_model:getShowData(data_index))
    elseif msg == "look_hero_info" then
        self:showHeroInfo()
    end
end

--调用sdk充值
function M:buyForSDK(data)
    if data then
        --免费
        if data.price == 0 then
            local function netCallback(response)
                if response then
                    self.m_model:updateGiftDataFree(response.gift_data)
                    self.m_view:updateBagNode()
                    RewardUtil:rewardTipsByData(response.reward) --展示奖励
                end
            end
            local params = {}
            params.version = self.m_model:getVersion()
            params.gift_id = data.gift_id
            params.place_id = data.place
            self.m_model:getNetData("mood_shadow_receive_free_gift", params, netCallback)
        --付费    
        elseif data.charge_id then
            self.m_view:lockTouch()
            --代金券
            if self.m_model.is_tokens == true then
                self:buyUseVoucher(data.charge_id, function ()
                    self.m_model:updateGiftData(function () self.m_view:updateBagNode() end)
                    self.m_view:unlockTouch()
                end)
            --常规购买      
            else
                PayUtil:rechargeByChargeId(data.charge_id, function ()
                    if self.m_view then
                        self.m_model:updateGiftData(function () self.m_view:updateBagNode() end)
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
    self:openView("Pops.HeroLookInfo", {hero_id = 607, is_new = false})
end
return M
