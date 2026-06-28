local M = class("commonActiveLoginReceiveControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "backBtn" then    -- 返回
        self:updateMsg("refreshRedPoint", nil, "NationalBeautiful.NationalBeautifulMain")
        self:updateMsg("refresh_red_point", nil, self.m_model.refresh_main)
        self:closeView()
    elseif msg == "box_reward" then --领取奖励
        self:questRewardBox(data.data)
    elseif msg == "box_click" then  --点击奖励
        local rewards = data.data.cfg.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == 2})
    elseif msg == "buy_btn" then --购买战力
        local change_id = self.m_model:getBuyWarChargeId()
        local params = {cell_data = {xlsxData = {charge_id = change_id}}}
        self:buyForSDK(params)
    end
end

--领取奖励
function M:questRewardBox(data)
    local function netCallback(response)
        if response then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
        end
    end
    local params = {}
    params.vsn = self.m_model:getVersion()
    params.reward_id = data.id
    params.open_id = self.m_model.open_id
    self.m_model:getNetData("war_order_receive_common_reward", params, netCallback)
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
        if data.cell_data.xlsxData.price == 0 then
            local function netCallback(response)
                if response then
                    self.m_model:updateGiftDataFree(response.gift_data)
                    self.m_view:updateBagNode()
                    RewardUtil:rewardTipsByData(response.reward) --展示奖励
                end
            end
            local params = {}
            params.vsn = self.m_model:getVersion()
            params.paper_id = self.m_model.cur_page
            params.open_id = self.m_model.open_id
            params.place = data.cell_data.index
            self.m_model:getNetData("active_common_gift_buy", params, netCallback)
            --付费    
        elseif data.cell_data.xlsxData.charge_id then
            self.m_view:lockTouch()
            --代金券
            if self.m_model.is_tokens == true then
                self:buyUseVoucher(data.cell_data.xlsxData.charge_id, function ()
                    self:updateGiftData(function ()
                        self.m_view:refreshUI() end)
                    self.m_view:unlockTouch()
                end)
                --常规购买      
            else
                PayUtil:rechargeByChargeId(data.cell_data.xlsxData.charge_id, function ()
                    if self.m_model and self.m_view then
                        self:updateGiftData(function ()
                            if self.m_view then
                                self.m_view:refreshUI()
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

--刷新数据
function M:updateGiftData(callback)
    local function netCallback(response)
        self.m_model:updateData(response)
        --self.m_view:refreshUI()
        if callback then
            callback()
        end
    end
    self.m_model:getNetData("war_order_common_war_order_index", {open_id = self.m_model.open_id, vsn = self.m_model.version}, netCallback)
end

return M
