local M = class("LanternFestivalControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh" ,nil ,"parent")

        self:closeView()
    elseif string.find(msg,"lantern_btn") then
        local x = string.find(msg,"lantern_btn")
        self:openView("LanternFestival.LanternFestivalRiddles")
    elseif msg == "guide_btn" then --快速导航   
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
    elseif msg == "fun_play_btn" then  --庙会趣玩
        StatisticsUtil:doPointActive(274,self.m_model.m_version)
        if self.m_model:getActStatus() == 1 then
            self:openView("LanternFestival.LanternFestivalFunPlay", {help_id = self.m_model.m_help_id,
                                                                     version = self.m_model.m_version,
                                                                     cur_day = self.m_model.m_day,
                                                                     quests = self.m_model.m_quests,
                                                                     score = self.m_model.m_score,
                                                                     recv_list = self.m_model.m_recv_list })
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "guess_btn" then
        StatisticsUtil:doPointActive(272,self.m_model.m_version)
        if self.m_model:getActStatus() == 1 then
            self:openView("LanternFestival.LanternFestivalRiddles", {cur_day = self.m_model.m_day,
                                                                     status = self.m_model.m_status,
                                                                     is_done = self.m_model.m_is_done,
                                                                     version = self.m_model.m_version,
                                                                     help_id = self.m_model.m_help_id})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "market_btn" then --上元集市
        StatisticsUtil:doPointActive(273,self.m_model.m_version)
        RedPointUtil:saveLocalRedPointFreshTime("lantern_market_once")
        self:openView("LanternFestival.LanternFestivalMarket", {help_id = self.m_model.m_help_id, 
                                                                version = self.m_model.m_version,
                                                                exchange = self.m_model.m_exchange,
                                                                end_ts = self.m_model.m_end_ts})
    elseif msg == "shop_btn" then
        StatisticsUtil:doPointActive(275,self.m_model.m_version)
        if self.m_model:getActStatus() == 1 then
            local params = {}
            params.help_id = self.m_model.m_help_id
            params.is_tokens = self.m_model.is_tokens or false
            params.version = self.m_model.m_version
            params.gift_end_ts = self.m_model.m_data.gift_end_ts
            params.gifts = self.m_model.m_data.gifts
            params.clothes_gifts = self.m_model.m_data.clothes_gifts
            self:openView("LanternFestival.LanternFestivalShop", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "refresh_data" then
        if data then
            self.m_model:initData(data)
            self.m_view:refreshUI()
        end
    elseif msg == "refresh_index" then
        self:requestIndexData()
    elseif msg == "help_btn" then
        local params = {}
        params.title = "lantern_festival_text_0001"
        params.content = self.m_model.m_help_id
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:requestIndexData()
    local function netCallback(response)
        if self.m_view then
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
        end
    end
    self.m_model:getNetData("active_lantern_index", {}, netCallback)
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

function M:requestRankData(is_cross)
    if self.m_model:needRequest(is_cross) then
        local function netCallback(response)
            if self.m_view then
                self.m_model:setCurCross(is_cross)
                self.m_model:initData(response)
                self.m_view:refreshUI(true)
            end
        end
        self.m_model:getNetData("world_all_rank", { is_cross = is_cross }, netCallback)
    else
        self.m_model:setCurCross(is_cross)
        self.m_view:refreshUI(true)
    end
end
return M;
