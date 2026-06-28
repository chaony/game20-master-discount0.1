local M = class("MillionairePopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red", nil, "Millionaire.MillionaireMain")
        self:closeView()
    elseif msg == "buy" then
        if self.m_model.current_time < data.index then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("millionaire_text_011"), delay_close = 2})
            return
        elseif self.m_model.is_show_time then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("millionaire_text_014"), delay_close = 2})
            return
        end
        self:buyForSDK(data)
    elseif msg == "tab_btn_1" then
       self:changeItem(1)
    elseif msg == "tab_btn_2" then
        self:changeItem(2)
    elseif msg == "tab_btn_3" then
        self:changeItem(3)
    end
end

--二级页签切换
function M:changeItem(id)
    if id ~= self.m_model.show_id then
        local red_key = self.m_model:getRedPointKey(id)
        if red_key then
            RedPointUtil:saveLocalRedPointFreshTime(red_key)
        end
        self.m_model.show_id = id
        self.m_view:refreshUI()
    end
end

--调用sdk充值
function M:buyForSDK(data)
    if data then
        --免费
        if data.cell_data.price == 0 then
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
            params.place_id = data.cell_data.place
            self.m_model:getNetData("hero_event_receive_free_gift", params, netCallback)
            --付费    
        elseif data.cell_data.charge_id then
            self.m_view:lockTouch()
            --代金券
            if self.m_model.is_tokens == true then
                self:buyUseVoucher(data.cell_data.cfg.charge_id, function ()
                    self.m_model:updateGiftData(function () self.m_view:updateBagNode() end)
                    self.m_view:unlockTouch()
                end)
                --常规购买      
            else
                PayUtil:rechargeByChargeId(data.cell_data.charge_id, function ()
                    if self.m_model and self.m_view then
                        self:updateGiftData(function ()
                            if self.m_view then
                                self.m_view:refreshUI(true)
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

function M:updateGiftData(callback)
    local function netCallback(response)
        self:updateMsg("refresh_ui", { data = response }, "Millionaire.MillionaireMain")
        self.m_model:updateServerData(response)
        if callback then
            callback()
        end
    end
    self.m_model:getNetData("user_payment_mult_step_rebate_index", nil, netCallback)
end

function M:updateTime()
    self.m_view:updateActivityTimer()
end


return M
