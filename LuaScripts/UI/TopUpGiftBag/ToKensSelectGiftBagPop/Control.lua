local M = class("ToKensSelectGiftBagPopControl", LikeOO.OOControlBase)

function M:onEnter()
    self:registerNextDayRefresh()
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        self:closeView()
    elseif msg == "refresh_data" then
        self.m_view:refreshUI()
    elseif msg == "open_gift_bag" then
        if data == 153 then --盗帅礼包
            self:openView("Activities.Voyage.VoyageGiftBag", {is_token= true})
        elseif data == 115 then
            self:openView("GiftBag.GiftBagScrollShopPop", {is_token = true})
        elseif data == 171 then
            self:openView("JuBaoShan.JuBaoShanGiftBag", {is_token = true})
        elseif data == 122 or data == 123 or data == 124 then
            self:openView("Summer.SummerMain",{is_token= true, open_sub_id =data})
        elseif data == 236 then
            self:questForOpenMoonShadowGift()
        elseif data == 230 or data == 227 then  --灵鹿迎新礼包屋
            local curActivityData = ConfigManager:getCfgByName("active_recharge")
            local targetStage = 0
            for _, itemData in pairs(curActivityData) do
                if itemData.open_id == 230 or itemData.open_id == 227 then
                    targetStage = itemData.stage_id
                    break
                end
            end
            local curStage = UserDataManager:getCurStage()
            if curStage >= targetStage then
                self:openView("DoubleFestivalActivity.DoubleFestivalMain",{jumpIndex = data == 230 and 4 or 1, open_id = -1})
            else
                local stageData = ConfigManager:getCfgByName("stage")
                local targetStageData = stageData[targetStage]
                GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey(targetStageData.map_point_name), delay_close = 2})
            end
        elseif data == 248 then
            self:questForOpenEvilShadowGift()
        elseif data == 244 then
            self:openView("YinTower.YinTowerGiftPop", {is_token = true})
        elseif data == 245 then
            self:openView("BudoServer.BudoServerGiftPop", {is_token = true})
        elseif data == 261 then
            self:openView("GiftBag.CelebrateNewYear", {is_token = true})
        elseif data == 275 then
            self:openView("LanternFestival.LanternFestivalShop", {is_token = true})
        elseif data == 288 then
            self:openView("GiftBag.SecretRewardGiftPop", {is_token = true})
        elseif data == 286 then
            self:openView("SimulateLift.SimulateToKen", {is_token = true})
        elseif data == 264 then
            self:openView("Activities.FamilyDinner.FamilyDinner", {is_token = true})
        elseif data == 265 then
            self:openView("Activities.TinShot.TinShot", {is_token = true})
        elseif data == 292 then
            self:openFlowerFestival()
        elseif data == 294 then
            self:openView("WdTower.WdTowerGiftPop", {is_token = true})
        elseif data == 284 then
            local function callback(response)
                if response and response["end"] == 1 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                    return
                end
                local params = {}
                params.version = response.version
                params.is_token = true
                self:openView("GuJianQiTan.GuJianQiTanGift", params)
            end
            self.m_model:getNetData("ancient_sword_and_wonderland_index", nil, callback)
        elseif data == 313 then
            local active_data = UserDataManager:getActivesRechargeDataByOpenId(313)
            if active_data then
                self:openView("SeasonPreview.SeasonGiftBag", {active_data = active_data, is_token = true})
            end
        elseif data == 309 then -- 四方争霸
            local params = {}
            params.is_token = true
            self:openView("Activities.FourForceWar", params)
        elseif data == 310 then -- 游园
            self:openView("Activities.EnjoySpring.LiteratureShop", {is_token = true})
        elseif data == 314 then
            local heroDraw = ConfigManager:getCommonValueById(120,0)
            if heroDraw == 1 then
                self:openView("LuckyDraw.HeroDraw", {is_token = true})
            else
                self:openView("LuckyDraw.LuckyDraw", {is_token = true})
            end
        elseif data == 324 then
            local activeXlsxData = UserDataManager:getActivesRechargeDataByOpenId(324)
            local params = {}
            params.is_token = true
            params.version = activeXlsxData.version
            self:openView("Activities.DeliciousFeast.DeliciousFeastGiftBag", params)
        elseif data == 329 then
            local activeXlsxData = UserDataManager:getActivesRechargeDataByOpenId(329)
            local params = {}
            params.is_token = true
            params.openId = 329
            params.version = activeXlsxData.version
            self:openView("HalfAnniversary.HalfAnniversaryGiftBag", params)
        elseif data == 330 then
            local activeXlsxData = UserDataManager:getActivesRechargeDataByOpenId(330)
            local params = {}
            params.is_token = true
            params.m_openId = 330
            params.m_version = activeXlsxData.version
            self:openView("DoubleFestivalActivity.SmashEggBuyPop", params)
        elseif data == 339 then
            self:openView("Raccon", {is_token = true})
        elseif data == 354 then
            local activeXlsxData = UserDataManager:getActivesRechargeDataByOpenId(354)
            local params = {}
            params.is_token = true
            params.openId = 354
            params.versionId = activeXlsxData.version
            self:openView("Activities.DragonBoat.DragonBoatGiftBag", params)
        elseif data == 364 then
            self:openView("GiftBag.MonthChargePop", {is_token = true})
        elseif data == 371 then
            local activeXlsxData = UserDataManager:getActivesRechargeDataByOpenId(371) or {}
            self:openView("FineClothes", {is_token = true, version = activeXlsxData.version})
        elseif data == 370 then
            local params = { openId = 370,is_token = true }
            self:openView("CoolSummer.CoolSummerGiftBag", params)
        elseif data == 369 then
            local params = {openId =369,is_token = true}
            self:openView("CoolSummer.CoolSummerSecret",params)
        elseif data == 373 then
            self:openView("QiXi.QiXiMain", {is_token = true})
        elseif data == 380 then
            self:openView("DailyPurchaseRestriction", {is_token = true}) 
        elseif data == 385 then
            self:openView("ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsMain", {is_token = true})
        elseif data == 87 then
            local version = UserDataManager:getOpenActiveVersion(87)
            local push_gifts = UserDataManager.m_limit_push
            if next(push_gifts) ~= nil then
                self:openView("GiftBag.LimitPop", {push_gift = push_gifts,is_token = true})
            end
        elseif data == 384 then
            self:openView("LimitedHero", {is_token = true})
        elseif data == 393 then
            self:openView("Chivalry.ChivalryMain", {is_token = true})
        elseif data == 403 then
            self:openView("WindAndCloud.WindAndCloudMain", {is_token = true})
        elseif data == 408 then
            self:openView("NationalBeautiful.NationalBeautifulMain", {is_token = true})
        elseif data == 419 then --周年庆
            self:openView("CelebrateOneYear.CelebrateOneYearMain", {is_token = true})
        elseif data == 433 then
            local active_data = UserDataManager:getActivesRechargeDataByOpenId(433)
            if active_data then
                self:openView("LuckyRabbitHut.LuckyRabbitGiftPop", {active_data = active_data,open_id = 433, is_token = true})
            end
        elseif data == 436 then --忠义无双
            self:openView("Loyalty.LoyaltyMain", {is_token = true})
        elseif data == 450 then --侠客岛
            self:openView("Xiakedao", {is_token = true})
        elseif data == 470 then --前缘招募，心愿助力
            self:openView("Predestined.PredestinedWashHelpPop", {is_token = true})
        end
    end
end

--跨天后刷新接口
function M:registerNextDayRefresh()
    local server_time = UserDataManager:getServerTime()
    local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
    local end_times = next_fresh_time + 24 * 3600
    local diff_time = (end_times - server_time) + 3 --过三秒再刷新
    EventDispatcher:registerTimeEvent(
        "refresh_token_select_giftbag_timer",
        function()
            self.m_view:refreshUI()
        end,
        diff_time,
        diff_time
    )
end

--发送打开月影传说礼包申请
function M:questForOpenMoonShadowGift()
    local function callback(response)
        if response and response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end

        local activity_item = response.charge_actives[1] or {} --礼包活动
        if activity_item.open_status == 0 then --未开启
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
            return
        elseif activity_item.open_status == 2 then --展示时间
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end

        local server_time = UserDataManager:getServerTime()
        local start_time = server_time
        if activity_item.start_ts then
            start_time = activity_item.start_ts
        end
        local current_day = math.floor((server_time - start_time) / (60 * 60 * 24)) + 1
        if current_day < 1 then
            current_day = 1
        elseif current_day > 7 then
            current_day = 7
        end
        self:openView("MoonShadow.MoonShadowGift", {version = activity_item.version or 0,
                                                    current_day = current_day,
                                                    gift_data = response.gift_data or {},
                                                    end_ts = activity_item.end_ts,
                                                    is_token = true})
    end
    self.m_model:getNetData("mood_shadow_index", nil, callback)
end

--发送打开魅影传说礼包申请
function M:questForOpenEvilShadowGift()
    local function callback(response)
        if response and response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end

        local activity_item = response.charge_actives[1] or {} --礼包活动
        if activity_item.open_status == 0 then --未开启
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
            return
        elseif activity_item.open_status == 2 then --展示时间
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end

        local server_time = UserDataManager:getServerTime()
        local start_time = server_time
        if activity_item.start_ts then
            start_time = activity_item.start_ts
        end
        local current_day = math.floor((server_time - start_time) / (60 * 60 * 24)) + 1
        if current_day < 1 then
            current_day = 1
        elseif current_day > 7 then
            current_day = 7
        end

        -- 唐伯虎直接进主界面
        local open_active_data = UserDataManager:getOpenActiveData(270)
        static_rootControl:openView("ActiveCurrent.ActiveCurrentMain",{open_active_data = open_active_data, is_token = true,version = activity_item.version or 0,})
        --self:openView("EvilShadow.EvilShadowGift", {version = activity_item.version or 0,
        --                                            current_day = current_day,
        --                                            gift_data = response.gift_data or {},
        --                                            end_ts = activity_item.end_ts,
        --                                            is_token = true})
    end
    self.m_model:getNetData("evil_shadow_index", nil, callback)
end

function M:openFlowerFestival()
    local function callback(response)
        if response and response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end
        self:openView("FlowerFestival.FlowerGiftBag", {version = response.vsn, openId = 292, is_token = true})
    end
    self.m_model:getNetData("flower_festival", nil, callback)
end

function M:destroy()
    EventDispatcher:unRegisterEvent("refresh_token_select_giftbag_timer")
    M.super.destroy(self)
end

return M