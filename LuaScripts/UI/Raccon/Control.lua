local M = class("RacconControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh" ,nil ,"parent")
        self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        if self.m_model.m_is_tokens == true then
            self:closeView()
        else
            self:closeView()
            local not_close_tab = {}
            not_close_tab = {["Loading.SyncLoadBigLoading"] = 1, ["Loading.SmallLoading"] = 1, ["Loading.BattleLoading"] = 1, ["Loading.BigLoading"] = 1, ["Main.TotalWorld"] = 1}
            static_rootControl:closeAllViewPop(not_close_tab)
        end
    elseif string.find(msg,"lantern_btn") then
        local x = string.find(msg,"lantern_btn")
        self:openView("LanternFestival.LanternFestivalRiddles")
    elseif msg == "qlxs_btn" then --麒麟现世   
        self:openView("Raccon.RacconDate", {version = self.m_model:getActVsn(340)})
    elseif msg == "xkz_btn" then --侠客志   
        self:openView("Raccon.RacconXkz", {version = self.m_model:getActVsn(341)})
    elseif msg == "hxjkc_btn" then --集卡册 
        self:openView("Raccon.RacconCollect", {version = self.m_model:getActVsn(344)})
    elseif msg == "hxyyl_btn" then --浣熊摇摇乐   
        self:openView("Raccon.RacconTinShot", {is_token = self.m_model.m_is_tokens, version = self.m_model:getActVsn(314)})
    elseif msg == "hlsj_btn" then --花落谁家   
        self:openView("Raccon.RacconLuckDraw", {is_token = self.m_model.m_is_tokens, version = self.m_model:getActVsn(346), current_day = self.m_model.m_day}) 
    elseif msg == "hxlb_btn" then --礼包  
        self:openView("Raccon.RacconGift", {is_token = self.m_model.m_is_tokens, version = self.m_model:getActVsn(345, true)})
    elseif msg == "fctj_btn" then --小游戏
        self:openView("Raccon.RacconGameEntrance")
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
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
        local open_condition = ConfigManager:getCfgByName("open_condition")
        local o_item = open_condition[339] or {}
        params.title = o_item.name or ""
        local content = self.m_model:getMainCfgVByK("raccoon_des") or "tid#XiaoHuanXiongDes_1"
        params.content = content
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
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("raccon_index", {}, netCallback)
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
