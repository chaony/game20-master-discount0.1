local M = class("TinShotGiftBagControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("update_red_point", nil, "GiftBag.CelebrateNewYear")
        if self.m_model.m_is_token == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
    elseif msg == "buy_btn" then
        self:highGachaVoyageBuyGift(data)
    elseif msg == "update_data" then
        self.m_model:initData(data)
        self.m_view:refreshUI()
    end
end

-- --新年活动 购买元宝礼包 gift_id: 1
function M:highGachaVoyageBuyGift(data)
    local cell_data = data.cell_data
    local sort = cell_data.cfg.sort or 1
    if sort == 1 then -- 元宝
        local function netCallback(response)
            self:netCheckEndTips(response)
            self.m_model:initData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("update_red_point", nil, "Activities.TinShot.TinShot")
            if response.update == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            end
        end
        local params = {gift_id = cell_data.id, version = self.m_model.m_version}
        self.m_model:getNetData("spring_festival_buy_draw_gift", params, netCallback)
    elseif sort == 2 then -- 花钱购买
        self:buyForSDK(cell_data.cfg.charge_id, function()
            self:RefreshOneTagData()
        end)
    else
        Logger.logError(sort, "ship_gift sort is error ")
    end
end

function M:buyForSDK(charge_id, callback)
    if self.m_model.m_is_token == true then
        self:buyUseVoucher(charge_id, function ()
            if callback then
                callback()
            end
        end)
        return
    end
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        if callback then
            callback()
        end
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(2, function ()
        self.m_view:unlockTouch()
        if callback then
            callback()
        end
        self.timer_id = nil
    end)
    PayUtil:rechargeByChargeId(charge_id, function ()
        if self.m_view then
            self.m_view:unlockTouch()
            if callback then
                callback()
            end
            if self.timer_id then
                self:removeTimer(self.timer_id)
                self.timer_id = nil
            end
        end
    end)
end

--使用代金券购买
function M:buyUseVoucher(data, callback)
    local function receivetCallback(response)
        self:RefreshOneTagData()
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

function M:RefreshOneTagData()
    self.m_model:getNetData("spring_festival_index",nil, function( data )
        self:netCheckEndTips(data)
        self.m_model:initData(data)
        self:updateMsg("update_red_point",nil, "Activities.TinShot.TinShot")
        if self.m_view then
            self.m_view:refreshUI()
        end 
    end)
end


function M:netCheckEndTips(response)
    if response and response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:updateMsg(99999)
    end
end

return M
