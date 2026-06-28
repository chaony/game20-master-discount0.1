local M = class("ChivalryFillControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(4.5, handler(self, self.UpdateTime))
    self.m_timer_id2 = self:setTimer(1, handler(self, self.UpdateTime2))
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        --if self.m_model.is_token == true then
        --    self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        --end
        --self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refreshRedPoint", nil, "Chivalry.ChivalryMain")
        self:closeView()
    elseif msg == "btn_closeBtn" then
        self:closeView()
    elseif msg == "reward_btn" then --奖励预览
        self:openView("LuckyDraw.LuckyDrawRewardPreview", {version = self.m_model.m_data.version})
    elseif msg == "gift_btn" then --礼包
        if self.m_model.show_stage + 6 ~= self.m_model.m_data.version then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            return
        end
        RedPointUtil:saveLocalRedPointFreshTime("TongYongGachaGift")
        self.m_view:refreshRedPoint()
        local function closeCall()
            self.m_view:refreshUI()
        end
        local active_datas = UserDataManager:getActivesRechargeDataByOpenId(318)
        self:openView("DoubleFestivalActivity.SmashEggBuyPop", {m_openId = 318, m_version = active_datas.version, is_token = self.m_model.is_token, callback = closeCall})
    elseif msg == "change_btn" then --兑换
        local active_datas = self.m_model:getActiveData(self.m_model.m_data.version)
        if active_datas then
            --self:updateMsg("jump_giftbag2", {active_id = active_datas.active_id}, "parent")
            local refreshRedPointCallback = function()
                self.m_view:refreshRedPoint()
            end
            self:openView("commonActive.commonExchangeShop",{open_id = 396,version = self.m_model.m_data.version - 6,callback = refreshRedPointCallback})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("luckyDraw_str_0002"), delay_close = 2})
        end
    elseif msg == "fill_one_btn" then --砸一次
        if self.m_model.show_stage + 6 ~= self.m_model.m_data.version then
            return
        end
        local coin_data = self.m_model:getOneCost()
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
        
            self.m_model:drawFromServer(1, function( data )
                self:netCheckEndTips(data)
                --table.merge(self.m_model.m_msg_data, data.draw_msgs)
                --self:updateMsg("refreshData", data, "GiftBag.CelebrateNewYear.NewYearSkipShop")
                --self.m_view:refreshSpineUI()
                self.m_view:refreshUI()
                RewardUtil:rewardTipsByData(data.reward)
            end)
    elseif msg == "fill_ten_btn" then --砸十次
        if self.m_model.show_stage + 6 ~= self.m_model.m_data.version then
            return
        end
        local coin_data = self.m_model:getTenCost()
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
        
            self.m_model:drawFromServer(10, function( data )
                self:netCheckEndTips(data)
                --table.merge(self.m_model.m_msg_data, data.draw_msgs)
                --self:updateMsg("refreshData", data, "GiftBag.CelebrateNewYear.NewYearSkipShop")
                --self.m_view:refreshSpineUI()
                self.m_view:refreshUI()
                RewardUtil:rewardTipsByData(data.reward)
            end)
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
    elseif msg == "update_quest_data" then --刷新全服进度
        self:updateQuestData()
    elseif msg == "stage_btn_1" then --故事入口1
        self:changeStore(1)
    elseif msg == "stage_btn_2" then --故事入口2
        self:changeStore(2) 
    elseif msg == "stage_btn_3" then --故事入口3
        self:changeStore(3)
    elseif msg == "legend_btn" then --传奇
        --if self.m_model.show_stage + 6 ~= self.m_model.m_data.version then
        --    self:openView("Chivalry/ChivalryPopTips",{version = self.m_model.show_stage,title = "hero_ui_str_0010",is_show_btn = 1,show_bg_img = "a_lbxkx_sshj_tc_tanchuangBJ"..self.m_model.show_stage})
        --    return 
        --end
        if self.m_model.sorce < self.m_model:getShowContent().score2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("chivalry_text_0012"), delay_close = 2})
            return
        end
        self:openView("Chivalry/ChivalryPopTips",{version = self.m_model.show_stage,title = "hero_ui_str_0010",is_show_btn = 1,show_bg_img = "a_lbxkx_sshj_tc_tanchuangBJ"..self.m_model.show_stage})
    elseif msg == "box_btn" then --宝箱
        local click_obj= self.m_view:findGameObject("box_btn")
        local rewards = self.m_model:getShowContent().reward_1 or {}
        if self.m_model.sorce ~= 100 then
            --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("chivalry_text_0012"), delay_close = 2})
            self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = click_obj.transform, show_check_mark = false})
        else
            
        end
    elseif msg == "rank_btn" then  --排行榜
        self:openView("commonActive.commonGachaTrainRankList",{open_id = self.m_model.open_id ,version = self.m_model.m_data.version})
    elseif msg == "legend_btn_1" then
        self:showStore(1)
    elseif msg == "legend_btn_2" then
        self:showStore(2)
    elseif msg == "legend_btn_3" then
        self:showStore(3)
    end
end

--展示故事
function M:showStore(id)
    self:openView("Chivalry/ChivalryPopTips",{version = id,title = "hero_ui_str_0010",is_show_btn = 1,show_bg_img = "a_lbxkx_sshj_tc_tanchuangBJ"..id})
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

--刷新全服进度
function M:updateQuestData()
    local function netCallback(response)
        self.m_model.sorce = response.sorce
        self.m_view:refreshQuestData(response.sorce)
    end
    self.m_model:getNetData("gacha_active_quest_score", {version = self.m_model.m_data.version}, netCallback)
end

--故事入口
function M:changeStore(store_id)
    self.m_model.show_stage = store_id
    if store_id > self.m_model.open_num then --未开启
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0259"), delay_close = 2})
        return
    elseif store_id < self.m_model.open_num then --已结束
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("activities_str_0007"), delay_close = 2})
        return
    end
    self.m_view:refreshStore(store_id)
    self.m_view:refreshQuestData(self.m_model.sorce)
end

function M:destroy()
    self.removeTimer(self.m_timer_id)
    self.removeTimer(self.m_timer_id2)
    M.super.destroy(self)
end

return M
