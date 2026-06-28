local M = class("SeasonGiftBagControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_is_token == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("refresh_red_point", nil, "SeasonPreview")
        self:closeView()
    elseif msg == "buy_btn" then
        self:highGachaVoyageBuyGift(data)
    elseif msg == "update_data" then
        self.m_model:initData(data)
        self.m_view:refreshUI()
    end
end

-- -
function M:highGachaVoyageBuyGift(data)
    local cell_data = data.cell_data
    local sort = cell_data.cfg.price_type or 1
    if sort == 1 or cell_data.cfg.price == 0 then -- 元宝
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
            self.m_model:initData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward)
        end
        local params = {}
        params.open_id = self.m_model.m_open_id
        params.vsn = self.m_model.m_version
        params.paper_id = 1
        params.place = data.index
        self.m_model:getNetData("active_common_gift_buy", params, netCallback)
    elseif sort == 2 then -- 花钱购买
        self:buyForSDK(cell_data.cfg.charge_id, function()
            self:refreshIndexData()
            self:updateMsg("refresh_red_point", nil, "SeasonPreview")
        end)
    else
        Logger.logError(sort, "ship_gift sort is error ")
    end
end

function M:buyForSDK(charge_id, callback)
    if self.m_model.m_is_token == true then
        self:buyUseVoucher(charge_id, function ()
            if self.m_view then
                self.m_view:refreshUI()
            end 
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
    self.timer_id = self:setOnceTimer(8, function ()
        if self.m_view then
            self.m_view:unlockTouch()
            if callback then
                callback()
            end
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
            if self.m_view then
                self.m_view:refreshUI()
            end
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


--  刷新
function M:refreshIndexData()
    local function netCallback(response)
        self:updateMsg("update_data", response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("active_common_gift_index", {open_id = self.m_model.m_open_id, vsn = self.m_model.m_version}, netCallback)
end

return M
