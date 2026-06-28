local M = class("TinShotSkipShopControl", LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        if self.m_model.is_tokens then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("refresh_red_point", nil, "GiftBag.CelebrateNewYear")
        self:closeView()
    elseif msg == "left_buy_btn" then
        local skins = self.m_model:getSkins()
        if #skins >= 2 then
            local data = skins[2];
            if data.hasBuy == false then
                self:buyForSDK(data.charge_id);
            end
        end
    elseif msg == "right_buy_btn" then
        local skins = self.m_model:getSkins()
        if #skins >= 2 then
            local data = skins[1];
            if data.hasBuy == false then
                self:buyForSDK(data.charge_id);
            end
        end
    elseif msg == "grow_check_btn_1" then
        local skins = self.m_model:getSkins()
        if #skins >= 2 then
            local left_skin = skins[2]
            self:showHeroInfo(left_skin)
        end
    elseif msg == "grow_check_btn_2" then
        local skins = self.m_model:getSkins()
        if #skins >= 2 then
            local right_skin = skins[1]
            self:showHeroInfo(right_skin)
        end
    elseif msg == "help_btn" then
        local spring_festival = ConfigManager:getCfgByName("spring_festival")
        local versionData = spring_festival[self.m_model.version] or {}
        local content = versionData.des
        local open_data = self.m_model:getActiveCfgByOpenId(261)
        local titleName = open_data.name
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    end
end

function M:UpdateTime()
    self.m_view:updateActivityTimer()
end

function M:showHeroInfo(data)
    local reward_data = RewardUtil:getProcessRewardData(data.reward[1])
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        self:openView("Pops.HeroLookInfo", {hero_id = heroId, is_new = false})
    elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
        self:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = reward_data.data_id})
    end
end

-- function M:RefreshOneTagData( charge_id )
--     local skins = self.m_model:getSkins();
--     if skins ~= nil then
--         for i, v in ipairs(skins) do
--             if v.charge_id == charge_id then
--                 table.insert(self.m_model.hasBuySkinIds, i);
--             end
--         end
--     end
--     self:updateMsg("update_data", nil, "GiftBag.CelebrateNewYear")
--     self.m_view:refreshUI();    
-- end

function M:RefreshOneTagData()
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
        table.merge(self.m_model.hasBuySkinIds,response.clothes_done)
        self:updateMsg("refresh_data", response, "GiftBag.CelebrateNewYear")
        self.m_view:refreshUI();  
    end
    self.m_model:getNetData("spring_festival_index", nil, netCallback)
end



--调用sdk充值
function M:buyForSDK(charge_id)
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
            self:RefreshOneTagData()
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


function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
