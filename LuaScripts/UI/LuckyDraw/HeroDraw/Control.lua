local M = class("HeroDrawControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(4.5, handler(self, self.UpdateTime))
    self.m_timer_id2 = self:setTimer(1, handler(self, self.UpdateTime2))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        if self.m_model.is_token == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "update_red_point" then
        
    elseif msg == "refresh_ui" then
        
    elseif msg == "btn_closeBtn" then
        self:closeView()
    elseif msg == "reward_show_btn" then --奖励预览
        self:openView("LuckyDraw.LuckyDrawRewardPreview", {version = self.m_model.m_data.version})
    elseif msg == "gift_btn" then --礼包
        RedPointUtil:saveLocalRedPointFreshTime("TongYongGachaGift")
        self.m_view:refreshRedPoint()
        local function closeCall()
            self.m_view:refreshUI()
        end
        self:openView("DoubleFestivalActivity.SmashEggBuyPop", {m_openId = 318, m_version = self.m_model.m_data.version, is_token = self.m_model.is_token, callback = closeCall})
    elseif msg == "change_btn" then --商城
        if self.m_model.active_datas then
            self:updateMsg("jump_giftbag2", {active_id = self.m_model.active_datas.active_id}, "parent")
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("luckyDraw_str_0002"), delay_close = 2})
        end
    elseif msg == "once_btn" then --砸一次
        local coin_data = self.m_model:getOneCost()
        for i, v in ipairs(coin_data) do
            local coin_data_config = RewardUtil:getProcessRewardData(v)
            if coin_data_config.user_num < coin_data_config.data_num then
                local flag = QuickOpenFuncUtil:hasCostsTips({ v})
                if not flag then
                    local text = Language:getTextByKey("new_str_0098", coin_data_config.name)
                    if coin_data_config.item_cfg.gain and coin_data_config.item_cfg.gain ~= "" then
                        text = text .. "\n" .. Language:getTextByKey(coin_data_config.item_cfg.gain)
                    end
                    GameUtil:lookInfoTips(self, {msg = text, delay_close = 2})
                end
                return
            end
        end

        --self.m_view:palySpineAnim(function ()
            self.m_model:drawFromServer(1, function( data )
                self:netCheckEndTips(data)
                --table.merge(self.m_model.m_msg_data, data.draw_msgs)
                --self:updateMsg("refreshData", data, "GiftBag.CelebrateNewYear.NewYearSkipShop")
                --self.m_view:refreshSpineUI()
                self.m_view:refreshUI()
                RewardUtil:rewardTipsByData(data.reward)
            end)
        --end)
    elseif msg == "ten_btn" then --砸十次
        local coin_data = self.m_model:getOneCost()
        for i, v in ipairs(coin_data) do
            local coin_data_config = RewardUtil:getProcessRewardData(v)
            if coin_data_config.user_num < coin_data_config.data_num * 10 then
                local flag = QuickOpenFuncUtil:hasCostsTips({ v})
                if not flag then
                    local text = Language:getTextByKey("new_str_0098", coin_data_config.name)
                    if coin_data_config.item_cfg.gain and coin_data_config.item_cfg.gain ~= "" then
                        text = text .. "\n" .. Language:getTextByKey(coin_data_config.item_cfg.gain)
                    end
                    GameUtil:lookInfoTips(self, {msg = text, delay_close = 2})
                end
                return
            end
        end

        --self.m_view:palySpineAnim(function ()
        self.m_model:drawFromServer(10, function( data )
            self:netCheckEndTips(data)
            --table.merge(self.m_model.m_msg_data, data.draw_msgs)
            --self:updateMsg("refreshData", data, "GiftBag.CelebrateNewYear.NewYearSkipShop")
            --self.m_view:refreshSpineUI()
            self.m_view:refreshUI()
            RewardUtil:rewardTipsByData(data.reward)
        end)
        --end)
    elseif msg == "help_btn" then
        local content = ""
        if self.m_model.active_datas then
            content = self.m_model.active_datas.des
        end
        local open_data = self.m_model:getActiveCfgByOpenId(self.m_model.open_id)
        local titleName = open_data.name
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    elseif msg == "update_data" then
        self:updateData()
    end
end

function M:updateData()
    local function netCallback(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("gacha_active_index", {}, netCallback)
end

--计时器
function M:UpdateTime(_, dt)
    dt = dt or 0
    self.m_model:newxBigRewardIndex()
    self.m_view:refreshBigUI()
end

function M:netCheckEndTips(response)
    if response and response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:updateMsg(99999)
    end
end

function M:UpdateTime2()
    self.m_view:updateTime()
end

function M:destroy()
    self.removeTimer(self.m_timer_id)
    self.removeTimer(self.m_timer_id2)
    M.super.destroy(self)
end

return M
