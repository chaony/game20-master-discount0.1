local M = class("ActiveCurrentMainControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        if self.m_model.is_token then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("refresh_red_point", nil, "parent")
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "open_active" then --打开活动
        if data.cell_data.open_id == 249 then --传记
            StatisticsUtil:doPointActive(249,self.m_model.m_data.version)
            self:updateMsg("date_btn",data)
        elseif data.cell_data.open_id == 248 then --礼包
            StatisticsUtil:doPointActive(248,self.m_model.m_data.version)
            self:updateMsg("gift_btn",data)
        elseif data.cell_data.open_id == 250 then --战斗
            StatisticsUtil:doPointActive(250,self.m_model.m_data.version)
            self:updateMsg("battle_btn",data)
        elseif data.cell_data.open_id == 268 then --兑换
            StatisticsUtil:doPointActive(268,self.m_model.m_data.version)
            self:updateMsg("share_btn",data)
        elseif data.cell_data.open_id == 269 then --抽奖
            StatisticsUtil:doPointActive(269,self.m_model.m_data.version)
            self:updateMsg("luck_draw",data)
        end
        audio:SendEvtUI("UI_BYXS_Popup_2")
    elseif msg == "grow_btn" then
        local open_status = self.m_model:getActiveStatus()
        if open_status == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1149"), delay_close = 2})
            return
        else
            if self:checkOpenStatus(128) then
                self:openView("ActiveCurrent.ActiveCurrentGrow",
                        {version = self.m_model.m_data.version,
                         hero_skin_data = self.m_model.hero_skin_data,
                         daily_recv_rewards = self.m_model.m_data.daily_recv_rewards,
                         is_token = self.m_model.is_token,
                         background = self.m_view.background})
            end
        end
    elseif msg == "date_btn" then --传记
        local open_status = self.m_model:getActiveStatus()
        if open_status == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            if self:checkOpenStatus(data.cell_data.open_id) then
                local active_data = self.m_model:getOpenActive(data.open_id)
                self:openView("ActiveCurrent.ActiveCurrentDate",
                        {version = self.m_model.m_data.version,
                         active_data = data,
                         current_day = self.m_model:setCurrentDay(),
                         score = self.m_model.m_data.score,
                         score_done = self.m_model.m_data.score_done,
                         task_detail_data = self.m_model.m_data.quests,
                         hero_skin_data = self.m_model.hero_skin_data,
                         background = self.m_view.background})
            end
        end
    elseif msg == "gift_btn" then  --礼包
        local open_status = self.m_model:getActiveStatus()
        if open_status == 2 or open_status == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            if self:checkOpenStatus(data.cell_data.open_id) then 
                self:openView("ActiveCurrent.ActiveCurrentGift",
                        {version = self.m_model.m_data.version,
                         active_data = data,
                         current_day = self.m_model:setCurrentDay(),
                         gift_data = self.m_model.m_data.gift_data,
                         end_ts = GameUtil:stringToTimesTamp(data.cell_data.cfg.end_time),
                         background = self.m_view.background,
                         hero_skin_data = self.m_model.hero_skin_data,
                         is_token = self.m_model.is_token,
                         hero_gift_times = self.m_model.m_data.hero_gift_times})
            end
        end
    elseif msg == "battle_btn" then
        local open_status = self.m_model:getActiveStatus()
        if open_status == 2 or open_status == 0then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            if self:checkOpenStatus(data.cell_data.open_id) then
                self:openView("ActiveCurrent.ActiveCurrentBattle", {version = self.m_model.m_data.version,
                                                                    current_day = self.m_model:setCurrentDay(),
                                                                    enemy = self.m_model:getEnemy(),
                                                                    heirloom = self.m_model:getHeirloom(),
                                                                    max_damage = self.m_model:getMaxDamage(),
                                                                    active_data = data,
                                                                    background = self.m_view.background,
                                                                    hero_skin_data = self.m_model.hero_skin_data,
                                                                    current_day = self.m_model:setCurrentDay()})
            end
        end
    elseif msg == "look_hero_info" then
        self:showHeroInfo()
    elseif msg == "share_btn" then
        local open_status = self.m_model:getActiveStatus()
        if open_status == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            self:openView("ActiveCurrent.ActiveCurrentExchangeShop", {version = self.m_model.m_data.version,
                                                                      active_data = data,
                                                                      exchange_done_data = self.m_model:getExchangeDoneData(),
                                                                      hero_skin_data = self.m_model.hero_skin_data,
                                                                      background = self.m_view.background})
            
        end
    elseif msg == "luck_draw" then
        local open_status = self.m_model:getActiveStatus()
        if open_status == 2 or open_status == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        else
            local current_day,new_current_day = self.m_model:setCurrentDay()
            self:openView("ActiveCurrent.ActiveCurrentLuckDraw", {version = self.m_model.m_data.version,
                                                                  active_data = data,
                                                                  lottery = self.m_model.m_data.lottery,
                                                                  hero_skin_data = self.m_model.hero_skin_data,
                                                                  background = self.m_view.background,
                                                                  day_price = self.m_model.m_data.day_price,
                                                                  current_day = new_current_day})
        end
    elseif msg == "refreshRedPoint" then
        if data and data == "no_request" then
        else
            self:refreshData()
        end
        self.m_view:refreshRedPoint()
        self.m_view:refreshActive()
    elseif msg == "help_btn" then
        local info_data = self.m_model:BasicInfo() --获取配置
        local params = {}
        params.title = info_data.name
        params.content = info_data.des
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refresh_data" then --刷新首页数据信息
        self:refreshData()
    elseif msg == "update_net_data_key" then
        if data and data.key then
            if self.m_model.m_data[data.key] ~= data.value then
                self.m_model.m_data[data.key] = data.value
            end
        end
    end
end

--刷新数据
function M:refreshData()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
        end
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("hero_event_index",{version = self.m_model.m_data.version }, netCallback)
end

function M:checkOpenStatus(open_id)
    --local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_id)
    local status = self.m_model:getActiveStatus(open_id)
    if status == 0 then
        GameUtil:lookInfoTips(self, {msg = "new_str_1149", delay_close = 2})
    end
    return status ~= 0
end

--展示英雄详情
function M:showHeroInfo()
    self:closeView("Pops.HeroLookInfo",nil, false)
    self:openView("Pops.HeroLookInfo", {hero_id = self.m_model.hero_id, is_new = false})
end

return M