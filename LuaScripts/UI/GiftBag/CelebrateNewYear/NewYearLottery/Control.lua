local M = class("NewYearLotteryControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(4.5, handler(self, self.UpdateTime))
    self.m_timer_id2 = self:setTimer(1, handler(self, self.UpdateTime2))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refresh_red_point",nil,"GiftBag.CelebrateNewYear")
        self:closeView()
    elseif msg == "update_red_point" then
        
    elseif msg == "refresh_ui" then
        
    elseif msg == "btn_closeBtn" then
        self:closeView()
    elseif msg == "reward_show_btn" then --奖励预览
        self:openView("GiftBag.CelebrateNewYear.NewYearRewardPreview")
    elseif msg == "gift_btn" then --礼包
        RedPointUtil:saveLocalRedPointFreshTime("spring_festival_shop_gift")
        self.m_view:refreshRedPoint()
        self:openView("GiftBag.CelebrateNewYear.NewYearLottery.NewYearLotteryGiftBag", {data = {version = self.m_model.version, draw_gifts = self.m_model.m_draw_gifts,is_token = self.m_model.is_token }})
    elseif msg == "change_btn" then --商城
        self:openView("Shop", {shop_type = 28})
    elseif msg == "once_btn" then --砸一次
        local coin_data = {103,5365,1}
        local coin_data_config = RewardUtil:getProcessRewardData(coin_data)
        if coin_data_config.user_num < coin_data_config.data_num then
            local flag = QuickOpenFuncUtil:hasCostsTips({ coin_data})
            if not flag then
                local text = Language:getTextByKey("new_str_0098", coin_data_config.name)
                if coin_data_config.item_cfg.gain and coin_data_config.item_cfg.gain ~= "" then
                    text = text .. "\n" .. Language:getTextByKey(coin_data_config.item_cfg.gain)
                end
                GameUtil:lookInfoTips(self, {msg = text, delay_close = 2})
            end
            return;
        end
        self.m_view:palySpineAnim(function ()
            self.m_model:drawFromServer(1, function( data )
                self:netCheckEndTips(data)
                table.merge(self.m_model.m_msg_data, data.draw_msgs)
                self:updateMsg("refreshData", data, "GiftBag.CelebrateNewYear.NewYearSkipShop")
                self.m_view:refreshSpineUI()
                self.m_view:refreshLeftCountUI()
                RewardUtil:rewardTipsByData(data.reward)
            end)
        end)
    elseif msg == "ten_btn" then --砸十次
        local coin_data = {103,5365,10}
        local coin_data_config = RewardUtil:getProcessRewardData(coin_data)
        if coin_data_config.user_num < coin_data_config.data_num then
            local flag = QuickOpenFuncUtil:hasCostsTips({ coin_data})
            if not flag then
                local text = Language:getTextByKey("new_str_0098", coin_data_config.name)
                if coin_data_config.item_cfg.gain and coin_data_config.item_cfg.gain ~= "" then
                    text = text .. "\n" .. Language:getTextByKey(coin_data_config.item_cfg.gain)
                end
                GameUtil:lookInfoTips(self, {msg = text, delay_close = 2})
            end
            return;
        end
        self.m_view:palySpineAnim(function ()
            self.m_model:drawFromServer(10, function( data )
                self:netCheckEndTips(data)
                table.merge(self.m_model.m_msg_data, data.draw_msgs)
                self:updateMsg("refreshData", data, "GiftBag.CelebrateNewYear.NewYearSkipShop")
                self.m_view:refreshSpineUI()
                self.m_view:refreshLeftCountUI()
                RewardUtil:rewardTipsByData(data.reward)
            end)
        end)
    elseif msg == "help_btn" then
        local spring_festival = ConfigManager:getCfgByName("spring_festival")
        local versionData = spring_festival[self.m_model.version] or {}
        local content = versionData.des
        local open_data = self.m_model:getActiveCfgByOpenId(261)
        local titleName = open_data.name
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    end
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
