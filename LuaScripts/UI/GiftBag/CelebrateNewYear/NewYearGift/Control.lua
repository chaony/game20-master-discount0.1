local M = class("NewYearGiftControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        if self.m_model.is_tokens then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
        self:updateMsg("update_data",nil,"GiftBag.CelebrateNewYear")
    elseif msg == "buy_btn_1" or msg == "buy_btn_2" or msg == "buy_btn_3" or msg == "buy_btn_4" then
        local curTime = self.m_model:getEndTs() - UserDataManager:getServerTime()
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
    elseif msg == "buy_btn" then
        audio:SendEvtUI("UI_Pay")
        local curTime = self.m_model:getEndTs() - UserDataManager:getServerTime()
        if curTime <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end
        if data then
            self:buyForSDK(data)
        end
    elseif msg == "refresh_index" then
        self:updateGiftData(function ()
            self.m_view:createGiftLoopScroll()
        end)
    elseif msg == "help_btn" then
        local spring_festival = ConfigManager:getCfgByName("spring_festival")
        local versionData = spring_festival[self.m_model.m_version] or {}
        local content = versionData.des
        local open_data = self.m_model:getActiveCfgByOpenId(261)
        local titleName = open_data.name
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    end
end

function M:updateGiftData(callback)
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
        self:updateMsg("refresh_data", response, "GiftBag.CelebrateNewYear")
        self.m_model:updateGiftDataFree(response)
        if callback then
            callback()
        end
    end
    self.m_model:getNetData("spring_festival_index", nil, netCallback)
end

--调用sdk充值
function M:buyForSDK(data)
    if data then
        --免费
        if data.price == 0 then
            local function netCallback(response)
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
                    self.m_model:updateGiftDataFree(response)
                    self.m_view:createGiftLoopScroll()
                    RewardUtil:rewardTipsByData(response.reward) --展示奖励
                    self:updateMsg("update_data", nil, "GiftBag.CelebrateNewYear")
                end
            end
            local params = {}
            params.version = self.m_model:getVersion()
            params.gift_id = data.gift_id
            params.place_id = data.place
            self.m_model:getNetData("spring_festival_receive_spring_gift", params, netCallback)
        --付费    
        elseif data.charge_id then
            self.m_view:lockTouch()
            --代金券
            if self.m_model.is_tokens == true then
                self:buyUseVoucher(data.charge_id, function ()
                    self:updateGiftData(function () 
                        self.m_view:createGiftLoopScroll()
                    end)
                    self.m_view:unlockTouch()
                end)
            --常规购买      
            else
                PayUtil:rechargeByChargeId(data.charge_id, function ()
                    if self.m_view then
                        self:updateGiftData(function () self.m_view:createGiftLoopScroll() end)
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
    local skin_tab = self.m_model:getSkins()
    local reward_data = RewardUtil:getProcessRewardData(skin_tab.reward[1])

    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        self:openView("Pops.HeroLookInfo", {hero_id = heroId, is_new = false})
    elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
        self:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = reward_data.data_id})
    end
end

--计时器
function M:UpdateTime()
    self.m_view:updateActivityTimer()
end


function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
