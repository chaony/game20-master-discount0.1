---@class MainControl : OOControlBase
---@field m_view MainView
---@field m_model MainModel
local M = class("MainControl", LikeOO.OOControlBase)
M.m_rolling = {}
M.lastAntiAddiction = 0

local __open_idle_pop_timer = "open_idle_pop_timer"

function M:onEnter()
    StatisticsUtil:onEnterGameToBi()
    UserDataManager.guide_data:init()
    UserDataManager.guide_data:resetCurGuide()
    --if SceneManager ~= nil then
    --    SceneManager:init(1)
    --end
    Logger.log(SceneManager.curScene.sceneId, "SceneManager.curScene.sceneId ==")
    local sceneId = SceneManager.curScene.sceneId
    if sceneId ~= 1 then
        SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
        local function callback()
            if self.m_model.m_params.heros then
                RewardUtil:rewardTipsByRewards(self.m_model.m_params.heros)
                self.m_model.m_params.heros = nil
            end
            self:syncEnterOnlyone()
        end
        self:openView("Loading.BigLoading", {callfunc = callback, show_time = 1})
    end

    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_INIT, {self, self.onInitChat})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_NEW_PRIVATE, {self, self.onrefreshPrivateRedPoint})
    EventDispatcher:registerEvent("show_new_hero", {self, self.openNewHero})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.ON_APPLICATION_WAKE_UP, {self, self.onApplicationWakeUp})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.SCREEN_CLICK_EVENT, {self, self.screenClickEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.COMMON_REFRESH, {self, self.commonRefreshEvent})

    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
    self.m_guide_file_name = "UI.Main.Guide"
    self:updateHeartBeat()
    self:registerRefreshTimer()
    self:registerNextDayRedPointRefresh()
    self:registerLimitMapEventRefreshTimer()
    if UserDataManager.new_ongoing_teams then
        self.m_view:visibleEncounterEventBtn(true)
        UserDataManager.new_ongoing_teams = false
    else
        self.m_view:visibleEncounterEventBtn(false)
    end
    --ResourceUtil:LoadRoleSound("Amb_2D")
    self:closePocoManager()
    GameMain.enter_main_flag = true
    LikeOO.OOUIbase:setBaseViewSortOrder()
    self:openIdlePopTimer()
    self.m_view:lockTouch()
    self:setOnceTimer(
            0.4,
            function()
                self.m_view:unlockTouch()
                self:onSyncEnter()
            end
    )
    self.webViewExit = false --问卷关闭了
    if SDKUtil.is_gmsdk then
        self:hasQuestion() --是否有问卷
        self:setOnceTimer(
                0.4,
                function()
                    self:setNineActive()
                end
        )
    end

    self:setPushInfo()
    --风云际会 红包刷新
    local active_data = UserDataManager:getActivesDataByOpenId(407)
    if active_data then
        self.m_view:updateRedBagView(true)
        local common = ConfigManager:getCfgByName("common")
        local timers = common[789] and common[789].value or 5
        local is_open = common[790] and common[790].value or 0 --活动默认关闭
        if is_open == 0 then
            self.m_view:updateRedBagView(false)
        else
            timers = timers >=5 and timers or 5
            self.m_red_bag_timer_id = self:setTimer(timers, handler(self, self.updateRedBagTime))
        end
    else
        self.m_view:updateRedBagView(false)
    end

    --轮播
    --添加定时器 轮播
    self:UpdateCarouselTime()
    self.timer_id = self:setTimer(5,handler(self,self.UpdateCarouselTime))
    --轮播
end

-- 推送设置
function M:setPushInfo()
    local pushUtil = PushUtil
    pushUtil:checkPush()
    -- 24小时后推
    pushUtil:hours24Push()
    -- 每日6点
    pushUtil:sixClockPush()
    -- 七日不登录
    pushUtil:sevenDayPush()
end

-- 加载完成后调用
function M:onSyncEnter()
    self:syncEnterOnlyone()
    self.m_view:playEncounterEventSound()
    self.m_view:refreshSceneTexture() --挂机场景texture
    self:showJieSuoTips()
    self:closeView("Loading.SyncLoadBigLoading")
end

local _ACTIVE_RECHARGE_TAB = {
    {open_id = 80, page_type = "war_order", pop_flag = "war_order_pop_flag", need_buy = UserDataManager.m_war_order.valor_payment_status and UserDataManager.m_war_order.valor_payment_status == 0}, -- 武林行侠令
    {open_id = 137, page_type = "sign_fund", pop_flag = "sign_fund_pop_flag", need_buy = UserDataManager.m_sign_fund.opened_lv and  UserDataManager.m_sign_fund.opened_lv < 2}, -- 签到基金
    {open_id = 85,  page_type = "grow_fund", pop_flag = "grow_fund_pop_flag", need_buy = UserDataManager.m_fund_status == 0 }, -- 成长基金
}

function M:getWakeUpData(open_id)
    local server_data = {}
    if open_id == 80 then
        server_data = UserDataManager.m_war_order
    elseif open_id == 137 then
        server_data = {sign_fund = UserDataManager.m_sign_fund}
    elseif open_id == 85 then
        server_data = {fund_quests = UserDataManager.m_fund_quests}
    end
    return server_data
end

--检查战令唤醒
function M:checkWakeUp()
    local params = {page_data = {}, page_type = {}, pop_flag = {}}
    params.from_main = true
    local open_flag = false
    for i = 1, #_ACTIVE_RECHARGE_TAB do
        local open_id = _ACTIVE_RECHARGE_TAB[i].open_id
        local active_data = UserDataManager:getActivesRechargeDataByOpenId(open_id)
        if open_id == 137 then
            active_data = UserDataManager.m_sign_fund
        end
        if active_data == nil then
        else
            local end_ts = active_data.end_ts or 0
            local re_time = end_ts - UserDataManager:getServerTime()
            if re_time > 0 and re_time <= 60 * 60 * 24 and _ACTIVE_RECHARGE_TAB[i].need_buy then --最后一天 且 未付费
                local show_flag = RedPointUtil:localRedPointJudge(_ACTIVE_RECHARGE_TAB[i].pop_flag)
                if show_flag then
                    open_flag = true
                    params.page_type[#(params.page_type) + 1] = _ACTIVE_RECHARGE_TAB[i].page_type
                    params.page_data[#(params.page_data) + 1] = self:getWakeUpData(open_id)
                    params.pop_flag[#(params.pop_flag) + 1] = _ACTIVE_RECHARGE_TAB[i].pop_flag
                end
            end
        end
    end
    if open_flag then
        self:openView("OperateActivity.WakeUpFundPop", params)
    end
end

function M:syncEnterOnlyone()
    local function __popPailian(idx)
        local popdata = UserDataManager.begin_pailian
        local curPopContent = popdata[idx]

        if curPopContent ~= nil then
            local is_pop = false

            local server_time = UserDataManager:getServerTime()
            if server_time > curPopContent.start_time and server_time < curPopContent.end_time then
                if BtnOpenUtil:isBtnOpen(187) then
                    -- if  curPopContent.role_level.up_limit >= lvl then
                    is_pop = true
                    -- end
                end
            end

            if is_pop then
                local param = {
                    end_call = function()
                        self:setOnceTimer(
                                0.3,
                                function()
                                    __popPailian(idx + 1)
                                end
                        )
                    end,
                    pop_data = curPopContent
                }
                --show v
                self:openView("Pops.BeginPop", param)
            else
                __popPailian(idx + 1)
            end
        else
            self.m_guide:checkGuide()
            self:updateMsg("main_quest_auto")
        end
    end

    if not self.onlyone then -- 只在开始游戏后调用一次
        self.onlyone = true

        self:checkFirstPop(
                function()
                    __popPailian(1)
                    self:checkWakeUp()
                end
        )

        self.m_view:refreshGachaTenGuide()
    end
end

--获取是否显示游戏内公告
function M:getGameNotice(callBack)
    local tab_value = nil
    SDKUtil:getNotice(
            function(params)
                if params.data ~= nil then
                    for i, v in pairs(params.data) do
                        if v.tab == "1" then
                            tab_value = v.tab
                            if self.m_model.m_game_notice ~= nil then
                                local server_ts = UserDataManager:getServerTime()
                                local day = GameUtil:NumberOfDaysInterval(self.m_model.m_game_notice,server_ts)
                                if day >= 1 then
                                    self:openView("Notice.InGameNoticePop",{callback = handler(self, self.checkFirstPop), callback_new = callBack})
                                    UserDataManager.local_data:setUserDataByKey("gameNotice",nil)
                                else
                                    --今日不显示弹窗
                                    self:checkFirstPop(callBack)
                                end
                            else
                                self:openView("Notice.InGameNoticePop",{callback = handler(self, self.checkFirstPop), callback_new = callBack})
                            end
                        end
                    end
                end
                if tab_value == nil then
                    self:checkFirstPop(callBack)
                end
            end,
            13
    )
end

--自动弹窗
function M:checkFirstPop(callBack)
    if self.m_model.m_player_back == true then --老玩家回归
        self.m_model.m_player_back = false
        self:openView("PlayerBack.PlayerBackMain", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
    elseif self.m_model.m_player_back_reward == true and (UserDataManager.comeback_status == 2 or UserDataManager.comeback_status == 4) then
        local userStatus = UserDataManager.comeback_status
        if userStatus == 2 then
            self.m_model.m_player_back_reward = false    --老玩家回归奖励
            self:openView("PlayerBack.PlayerBackToOld", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
        elseif userStatus == 4 then
            self.m_model.m_player_back_reward = false    --新回归界面
            self:openView("PlayerBack.NewPlayerRegress", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
        end
    elseif self.m_model.m_fine_clothes == true then --华服共赏
        self.m_model.m_fine_clothes = false
        local activeXlsxData = UserDataManager:getActivesRechargeDataByOpenId(371) or {}
        self:openView("FineClothes", {version = activeXlsxData.version, callback = handler(self, self.checkFirstPop), callback_new = callBack})
    elseif self.m_model.m_seven_pop == true then --进游戏后七日奖励糊脸
        self.m_model.m_seven_pop = false
        self:openView("GiftBag.DaySevenSPCardPop", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
    elseif self.m_model.m_first_charge_pop == true then
        self.m_model.m_first_charge_pop = false
        self:openView("GiftBag.FirstCharge", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
    elseif self.m_model.m_gameNotice_pop == true then
        self.m_model.m_gameNotice_pop = false
        self:getGameNotice(callBack)
    elseif self.m_model:checkTopArenaFinal() == true then
        self:openView(
                "PeakArena.PeakArenaResultPop",
                {callback = handler(self, self.checkFirstPop), callback_new = callBack}
        )
        UserDataManager.local_data:setUserDataByKey("top_arena_final", {})
    elseif self.m_model.m_push_gift_id then
        self:showPushGiftPop(
                function()
                    if callBack then
                        callBack()
                    end
                end
        )
    elseif self.m_model.m_choice_gift_id then
        self:showChoiceGiftPop(
                function()
                    if callBack then
                        callBack()
                    end
                end
        )
    elseif self.m_model.home_show_data ~= nil and self.m_model.home_show_data[1] ~= nil and self.m_model.m_nine_active then --九尾拍脸
        self.m_model.m_nine_active = false
        if SDKUtil.is_gmsdk then
            local data = self.m_model.home_show_data[1]
            SDKUtil:openPage(function(params)
                if params ~= nil and params.data ~= nil then
                    UserDataManager.local_data:setLocalDataByKey("windowId",params.data)
                    NineActiveUtil:setFaceClose(handler(self, self.checkFirstPop),callBack)
                end
            end, data.activityUrl,data.inGameId)
        end
    elseif self.m_model.m_common_quest_pop == true then --进游戏后小浣熊
        self.m_model.m_common_quest_pop = false
        self:openView("Raccon.RacconFinalPop", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
    elseif self.m_model.m_common_zhaoyun == true then -- 赵云壮胆
        self.m_model.m_common_zhaoyun = false
        self:openView("GiftBag.ZhaoYun", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
    elseif self.m_model.m_common_anniversary == true then -- 周年庆预热
        self.m_model.m_common_anniversary = false
        self:openView("GiftBag.Anniversary", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
    elseif self.m_model.m_is_first_season_preview == true then --赛季预告
        self:openView("SeasonPreview", {callback = handler(self, self.checkFirstPop), callback_new = callBack})
        self.m_model.m_is_first_season_preview = false
    else
        if callBack then
            callBack()
        end
    end
end

--限时推送弹窗
function M:showPushGiftPop(callBack)
    self.m_model:checkFirstPushGift()
    if self.m_model.m_push_gift_id then
        self:setOnceTimer(
                0.1,
                function()
                    self:updateMsg(
                            "click_dt_activity_btn",
                            {id = tonumber(self.m_model.m_push_gift_id), data_callback = callBack}
                    )
                end
        )
    else
        callBack()
    end
end

function M:showChoiceGiftPop(callBack)
    local group_id = self.m_model:checkFirstChoiceGift()
    local push_gifts = self.m_model:getChoiceGiftsByGroup(group_id)

    if self.m_model.m_choice_gift_id and next(push_gifts) then
        self:setOnceTimer(
                0.1,
                function()
                    self:updateMsg(
                            "click_choice_activity_btn",
                            {id = tonumber(self.m_model.m_choice_gift_id),
                             data_callback = callBack,
                             push_gift = push_gifts}
                    )
                end
        )
    else
        callBack()
    end
end


-- 屏蔽自动启动引导
function M:startGuide()
end

function M:registerRefreshTimer()
    local server_time = UserDataManager:getServerTime()
    local model_refresh_time = self.m_model.m_data.model_refresh_time or (server_time + 300)
    local diff_time = math.max(2, model_refresh_time - server_time)
    EventDispatcher:registerTimeEvent(
            "refresh_main_timer",
            function()
                self:updateMsg("common_refresh")
            end,
            diff_time,
            diff_time
    )
end

--跨天后红点刷新接口
function M:registerNextDayRedPointRefresh()
    local server_time = UserDataManager:getServerTime()
    local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
    local end_times = next_fresh_time + 24 * 3600
    local diff_time = end_times - server_time
    EventDispatcher:registerTimeEvent(
            "refresh_all_redpoint_timer",
            function()
                local function callfunc(response)
                    UserDataManager.red_dot = response.red_dot
                    UserDataManager:initClientRedPoint()
                    self:updateMsg("common_refresh")
                    EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT)
                end
                self.m_model:getNetData("red_dot", {is_login = 0}, callfunc, false, nil, GlobalConfig.POST)
            end,
            diff_time,
            diff_time
    )
end

function M:registerLimitMapEventRefreshTimer()
    local server_time = UserDataManager:getServerTime()
    local end_time = UserDataManager:getLimitMapEventMinEndTS()
    local diff_time = end_time - server_time
    if diff_time > 0 then
        EventDispatcher:registerTimeEvent(
                "limit_map_event_refresh_main_timer",
                function()
                    self:registerLimitMapEventRefreshTimer()
                    self.m_view:refreshBattleNode()
                end,
                diff_time,
                diff_time
        )
    end
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        -- 1上阵、2门派、3侠义、4恩怨、5英雄 6背包
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 6 then
        self:switchTabBtn(msg)
    elseif msg == "fingerSliding" then
        self:switchTabBtn(data)
    elseif msg == "close_btn" or msg == "closeNode_btn" or msg == "closeNode_bg" or msg == "big_close_btn" then
        self.m_view:closeNode()
        self.m_view:showChatDetailNode()
        if self.m_view.m_cur_tab_node == nil then
            self.m_guide:checkGuide()
        end
    elseif msg == "sect_btn_mask" then --事务
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(39)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "big_world_btn_mask" then --侠义
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(40)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "hero_btn_mask" then --武神
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(42)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    --elseif msg == "bazzar_btn_mask" then --蓬莱集市
    --    local red_flag, tips_str = BtnOpenUtil:isBtnOpen(350)
    --    GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "bag_btn_mask" then --行囊
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(43)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "mail_btn_mask" then --社交
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(56)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "task_btn_mask" then --任务
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(65)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "rune_scape_btn_mask" then --江湖
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(89)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    --elseif msg == "union_btn_mask" then --帮会
    --    local red_flag, tips_str = BtnOpenUtil:isBtnOpen(22)
    --    GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "total_arena_btn_mask" then --天下
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(192)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "hotel_btn_mask" then --酒楼
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(473)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "hero_btn" then --英雄列表
        --self.m_view:switchTabNode(5)
        local hero_list = UserDataManager.hero_data:getHerosId()
        if table.nums(hero_list) > 0 then
            self:openView("HeroBag", {mode = 1, is_quick_open_needed = true})
        else
            --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hero_ui_str_0013"), delay_close = 2})
        end
    --elseif msg == "bazzar_btn" then --蓬莱集市
    --    self:openView("PengLaiBazzar.PengLaiBazzarIsland", {})
    elseif msg == "bag_btn" then --背包
        --self.m_view:switchTabNode(6)
        self:openView("Item.ItemList", {isShowRunescapeItem = false})
    elseif msg == "sect_btn" then
        --QuickOpenFuncUtil:openFunc(9)
        self.m_view:switchTabNode(2)
        local mystic_inset = BtnOpenUtil:isBtnOpen(337)
        if mystic_inset then
            local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_main_finger", 1)
            if show_finger == 1 then
                UserDataManager.local_data:setUserDataByKey("mystic_main_finger", 0)
            end
        end
    elseif msg == "task_btn" then --任务
        self:openView("Task")
    elseif msg == "formation_btn" then
        --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
        self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.STAGE_SET_TEAM})
    elseif msg == "rune_scape_btn" then
        --self:openView("WorldTest")
        -- GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
        self.m_view:visibleEncounterEventBtn(false)
        local open_flag, tips = BtnOpenUtil:isBtnOpen(301)
        if open_flag then
            self:openView("WorldMapNew.WorldMapSelect")
        else
            self:openView("WorldMap.WorldMapMain")
        end
    elseif msg == "shop_btn" then --商店
        --if self.m_view.m_cur_tab_node then
        --    self.m_view.m_cur_tab_node:clickFunc(44)
        --end
        QuickOpenFuncUtil:openFunc(12)
    elseif msg == "hotel_btn" then --酒楼
        QuickOpenFuncUtil:openFunc(101)
    elseif msg == "jewel_btn" then --秘宝
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(479)
        if open_flag == false then
            GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
            return
        end
        local jewels = UserDataManager.jewel_data:getJewels()
        if next(jewels) then--有激活的宝物打开主页
            self:openView("Jewel")
        else --没有激活的宝物，直接打开宝物抽卡
            self:openView("Jewel.JewelGacha")
        end
    elseif msg == "tavern_btn" then --招募
        --if self.m_view.m_cur_tab_node then
        --    self.m_view.m_cur_tab_node:clickFunc(13)
        --end
        QuickOpenFuncUtil:openFunc(9)
    elseif msg == "top_arena_btn" then --巅峰论剑
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(64)
        if open_flag == true then
            self:openView("PeakArena.PeakArenaMain")
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(tips_str), delay_close = 2})
        end
    --elseif msg == "pet_btn" then --奇兽
    --    local red_flag, tips_str = BtnOpenUtil:isBtnOpen(350)
    --    if red_flag == true then
    --        self:openView("PetBreeding.PetBreedingMain")
    --    else
    --        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    --    end
    elseif msg == "mail_btn" then --邮件
        --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
        self:openView("Friend", {tab_index = 4})
    elseif msg == "friend_btn" then --好友
        self:openView("Friend")
    elseif msg == "rank_btn" then --风云榜
        --if self.m_view.m_cur_tab_node then
        --    self.m_view.m_cur_tab_node:clickFunc(30)
        --end
        QuickOpenFuncUtil:openFunc(22)
    elseif msg == "big_world_btn" then
        self:openView("Main.Outskirts")
    elseif msg == "total_arena_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(192)
        if open_flag == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
            return
        end
        self:openView("Main.TotalWorld")
    elseif msg == "chat_btn" then --聊天
        self:openView("Chat2")
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0306"), delay_close = 2})
    elseif msg == "chat_btn2" then
        self.m_model.m_chat_show = true
        self.m_view:showChatDetailNode()
    elseif msg == "chat_tab_btn" then
        --if data ~= self.m_model.m_cur_channel_id then
        self.m_model.m_cur_channel_id = data or self.m_model.m_cur_channel_id
        local msgs = self.m_model:getChatMsgByChannel(data)
        self.m_view:updateChatScroll(msgs)
        self.m_view:refreshPrivateChatRedPoint()
        --end
    elseif msg == "chat_show_btn" then
        self.m_model.m_chat_show = false
        self.m_view:showChatDetailNode()
    elseif msg == "open_chat_btn" then
        self:openView("Chat2", {channel_id = self.m_model.m_cur_channel_id})
    elseif msg == "open_side_btn" then --活动展开按钮
        self.m_view:lockTouch()
        self.m_view:updateSideStatus()
        self:setOnceTimer(
                0.25,
                function()
                    self.m_view:unlockTouch()
                end
        )
    elseif msg == "axian_timetable_btn" then
        local open_flag,tips_str = BtnOpenUtil:isBtnOpen(361)
        if open_flag then
            self:openView("Main.AXianTimeTable")
        else
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
        end
    elseif msg == "redpacket_btn" then
        local open_flag,tips_str = BtnOpenUtil:isBtnOpen(361)
        self:openView("WindAndCloud.WindAndCloudRedPacket" )
    elseif msg == "challenge_btn" then --挑战首领(打开配置阵容界面)
        if self.m_can_challenge == false then
            return
        end
        self.m_can_challenge = false
        self.m_view:playTiaoZhan()
        self.m_view:lockTouch()
        self:setOnceTimer(
                0.25,
                function()
                    self.m_can_challenge = true
                    self.m_view:unlockTouch()
                    local chapter_over = UserDataManager:getChapterOver()
                    if chapter_over then
                        self:playNextChapter()
                    else
                        --end
                        --end
                        --}
                        --)
                        --self:openView(
                        --"Loading.BattleLoading",
                        --{
                        --    callfunc = function(open_flag)
                        --        if open_flag == "open_view" then
                        if type(data) == "table" then
                            self:openStageFormation(data)
                        else
                            self:openStageFormation({click_obj = data})
                        end
                    end
                end
        )
    elseif msg == "challenge_btn_end" then
        --self:openStageFormation()
    elseif msg == "guaji_btn" then --快速挂机
        --self:openView("Pops.QuickHangUpPop", params)
        self:openHangReward(2)
    elseif msg == "guaji_box" then --挂机奖励
        self:openHangReward(1)
    elseif msg == "quest_special_btn" then
        self:openView("Task.TaskMainChapter")
    -- 事务里的按钮------------------------------------------------------------------------------------------------------
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "union_btn" then --工会
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(22)
        end
        --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
        QuickOpenFuncUtil:openFunc(23)
    elseif msg == "teahouse_btn" then -- 归州茶馆
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(21)
        end
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(21)
        if open_flag == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = tips_str, delay_close = 2})
            return
        end
        self:openView("Library.Library")
    elseif msg == "mystic_btn2" then -- 藏经阁
        --珍宝阁默认进入古物殿，若是还有其他活动开启了则进入主界面
        local another_open = false
        for k, v in pairs({220, 147, 256, 338}) do
            if BtnOpenUtil:isBtnOpen(v) == true then
                another_open = true
                break
            end
        end
        if another_open == false then
            local open_flag, tips_str = BtnOpenUtil:isBtnOpen(190)
            if open_flag == true then
                if self.m_model:getShareLv() == true then
                    self:openView("MagicWeapon")
                else
                    local lock_lv = ConfigManager:getCommonValueById(577,160)
                    GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("weapon_str_0006",lock_lv), delay_close = 2})
                end
            else
                GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
            end
        else
            if self.m_view.m_cur_tab_node then
                self.m_view.m_cur_tab_node:clickFunc(190)
            end
            --珍宝阁
            QuickOpenFuncUtil:openFunc(81)
            local mystic_inset = BtnOpenUtil:isBtnOpen(337)
            if mystic_inset then
                local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_city_finger", 1)
                if show_finger == 1 then
                    UserDataManager.local_data:setUserDataByKey("mystic_city_finger", 0)
                end
            end
        end
    elseif msg == "level_up_btn" then --升阶
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(9)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(9)
        end
        QuickOpenFuncUtil:openFunc(7)
    elseif msg == "tavern_btn" then --酒馆
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(13)
        end
        QuickOpenFuncUtil:openFunc(9)
    elseif msg == "shop_btn" then --商店
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(44)
        end
        QuickOpenFuncUtil:openFunc(12)
    elseif msg == "recycle_btn" then --前缘桥 原分解入口离别桥
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(36)
        end
        QuickOpenFuncUtil:openFunc(71)
    elseif msg == "recycle_sp_btn" then --SP抽卡
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(449)
        end
        QuickOpenFuncUtil:openFunc(71, {pool_id = GlobalConfig.GACHA_SP_ID})
    elseif msg == "common_lv_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(29)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(29)
        end
        QuickOpenFuncUtil:openFunc(21)
    elseif msg == "compass_btn" then
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(72)
        end
        StatisticsUtil:doPointActive(142,0)
        QuickOpenFuncUtil:openFunc(72)
    elseif msg == "magic_weapon_btn" then
        if self.m_model:getShareLv() == true then
            self:openView("MagicWeapon")
        else
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("weapon_str_0006",self.m_model.weapon_lock_lv), delay_close = 2 })
        end
    elseif msg == "equip_awaken_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(220)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        --GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0512"), delay_close = 2 })
        self:openView("EquipAwaken")
    elseif msg == "artifact_btn" then
        self:openView("EquipAwaken.ArtifactBookPop")
    elseif msg == "mystic_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(148)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        open_flag = UserDataManager.hero_data:checkAnySlotOpen()
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("mystic_str_00121"), delay_close = 2 })
            return
        end
        QuickOpenFuncUtil:openFunc(28)
        local mystic_inset = BtnOpenUtil:isBtnOpen(337)
        if mystic_inset then
            local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_magic_finger", 1)
            if show_finger == 1 then
                UserDataManager.local_data:setUserDataByKey("mystic_magic_finger", 0)
            end
        end
    elseif msg == "refreshUI" then
        self.m_view:refreshUI()
    elseif msg == "destinyStar_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(256)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        self:openView("DestinyStar")
    elseif msg == "penglai4_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(383)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        self:openView("Prestige.PrestigeMain")
        --self:closeView()
    elseif msg == "penglai5_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(417)
        if open_flag then
            self:openView("AwakeSystem.AwakeSystemMain")
        else
            GameUtil:lookInfoTips(self,{msg = tips_str, delay_close = 2})
        end
    elseif msg == "heaven_earth_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(338)
        if open_flag then
            self:openView("HeavenEarth")
        else
            GameUtil:lookInfoTips(self,{msg = tips_str, delay_close = 2})
        end
        -- 事务里的按钮 结束------------------------------------------------------------------------------------------------------
    elseif msg == "switch_main_tab" then
        if data.index == 6 then
            self:openView("Item.ItemList", {isShowRunescapeItem = false})
        else
            self.m_view:switchTabNode(data.index)
        end
    elseif msg == "select_hero" then --打开英雄详细信息
        self:openView("HeroInfo", {oid = data, race = self.m_model.m_race, pro = self.m_model.m_pro})
    elseif msg == "select_tj_hero" then --查看图鉴详细信息
        self:openView("HeroInfo", {tj_data = data, look_model = 2})
    elseif msg == "openUnion" then
        self:requestUnion()
    elseif msg == "helpdog_btn" then --拯救狗头
        self:openView("LittleGames.HelpDog",data)
    elseif msg == "check_btn" then --查看奖励
        self:openView("Map.StageRewardDetails", UserDataManager:getCurStage())
    elseif msg == "ditu_btn" then --地图
        self:openView("Map.MapPop", {stage_id = UserDataManager:getBattleStage()})
    elseif msg == "click_activity_btn" then
        self:openActivityBtn(data)
    elseif msg == "click_dt_activity_btn" then --限时礼包
        self:openView("GiftBag.LimitPop", data, nil, true)
    elseif msg == "click_choice_activity_btn" then --限时礼包
        data.open_type = "active"
        self:openView("GiftBag.ChoiceChargePop", data, nil, true)
    elseif msg == "first_recharge_btn" then -- 首充
        self:openView("FirstRechargePop")
    elseif msg == "jiantou" then --侧边栏收起
        self.m_view:packUp()
    elseif msg == "addMoney" then
        self:moneyFly(data)
    elseif msg == "bag_action" then
        self.m_view:bagAction()
    elseif msg == "open_btn" then --英雄列表下侧展开
        self.m_view.m_cur_tab_node:openBottom_Type(true)
    elseif msg == "shrink_btn" then
        self.m_view.m_cur_tab_node:openBottom_Type(false)
    elseif msg == "buy_solt_btn" then
        local count = self.m_model:getByHeroGride_Price()
        local params = {
            on_ok_call = function(msg)
                self:buySolt()
            end,
            text = string.format(Language:getTextByKey("new_str_0122"), count)
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "check_hero_guide" then --英雄列表切换图鉴按钮
        self.m_view:switchTabForHeroNode(data)
    elseif msg == "common_refresh" then
        self.m_model:requestUserMain(
                function()
                    self.m_view:refreshTabNode()
                    self.m_model:checkFirstPushGift()
                    self.m_model:checkFirstChoiceGift()
                    self.m_model:checkFirstLogin()
                    self.m_model:checkFirstCharge()
                    self.m_model:checkFineClothes()
                    --self.m_model:checkZhaoYun()
                    self:checkWakeUp()
                    if self:getChildCount() == 0 or (self:getChildCount() == 1 and self:hasChild("Loading.SmallLoading")) or
                            (self:getChildCount() == 2 and self:hasChild("HangReward")) or (self:getChildCount() == 2 and self:hasChild("GiftBag.FirstCharge"))
                    then
                        self:checkFirstPop(
                                function()
                                    if self.m_guide and self.m_view.m_cur_tab_node == nil then
                                        self.m_guide:checkGuide()
                                    end
                                end
                        )
                    else
                        if self.m_guide and self.m_view.m_cur_tab_node == nil then
                            self.m_guide:checkGuide()
                        end
                    end
                    self:mainQuestAutoReward(self.m_model.main_quest_auto)
                    self:registerRefreshTimer()
                    self:registerNextDayRedPointRefresh()
                    self.m_view:RefreshChatInfo()
                    self.m_view:refreshNewStage()
                    self.m_view:refreshSceneTexture()
                    NetWork:delayCheckHope()
                    --SDKUtil:CheckForceUpgrade() --字节检测软件更新
                    if SDKUtil.is_gmsdk then
                        self:hasQuestion() --是否有问卷
                    end
                end
        )
        if data and data.channel_id then
            self.m_model:setChatChannelId(data.channel_id)
        end
        self.m_view:showChatDetailNode()
        self:updateMsg("common_refresh", nil, "HeroBag")
    elseif msg == "check_guide" then
        if self.m_view.m_cur_tab_node == nil or (data and data.force_flag) then
            self.m_guide:checkGuide()
        end
    elseif msg == "refresh_red_point" then
        self.m_view:refreshRedPoint()
    elseif msg == "refresh_red_big_point" then
        local active_data = UserDataManager:getActivesDataByOpenId(407)
        if active_data then
            self.m_view:updateRedBagView(true)
            local function netCallback(response)
                if self.m_view then
                    local states = response.status or 0
                    self.m_view:updateRedBagPoint(states)
                end
            end
            local params = {}
            params.open_id = active_data.open_id
            params.vsn = active_data.version
            self.m_model:getNetData("redbag_red_dot", params, netCallback)
        else
            self.m_view:updateRedBagView(false)
            self:removeTimer(self.m_red_bag_timer_id)
        end

    elseif msg == "bounty_btn" then --悬赏
        if self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:clickFunc(16)
        end
        QuickOpenFuncUtil:openFunc(16)
    elseif msg == "labyrinth_btn" then
        local function netDataCallBack(response)
            if response.finish == 0 and response.cells ~= nil and _G.next(response.cells) ~= nil then
                QuickOpenFuncUtil:openFunc({18, response})
            else
                QuickOpenFuncUtil:openFunc({38, response})
            end
        end
        self.m_model:getNetData("maze_index", nil, netDataCallBack)
    elseif msg == "bag_tab_click" then
        self.m_view:switchTabForBagNode(data)
    elseif msg == "releaseUI" then --恢复MainUI
        self.m_view:releaseUI()
    --elseif msg == "next_stage" then --前往下一关
    elseif msg == "grudge_tab_click" then --恩怨切换
        self.m_view:switchTabForGrudge(data)
        self.m_model.m_grudge_tab_index = data
    elseif msg == "arena_normal" then --竞技场
        QuickOpenFuncUtil:openFunc(24)
    elseif msg == "arena_higher_order" then --高阶竞技场
        QuickOpenFuncUtil:openFunc(25)
    elseif msg == "arena_peak" then --巅峰竞技场
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
    elseif msg == "open_Bd" then --打开编队
        local data_def = {def_team = {}}
        self:openView(
                "Formation",
                {mode = GlobalConfig.BATTLE_MODE.MULT_FORMATION, formation_id = data, def_data = data_def}
        )
    elseif msg == "pdate_Bd" then --更新编队
        self.m_view:updateHero_bd()
    elseif msg == "pagoda_btn" then --锁妖塔
        QuickOpenFuncUtil:openFunc({10, 0})
    elseif msg == "race_btn_1" then
        local open_flag = self.m_model:getRaceTowerOpenByRace(1)
        if open_flag then
            QuickOpenFuncUtil:openFunc({10, 1})
        end
    elseif msg == "boss_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(50)
        if open_flag == true then
            self:openView("Activities.WorldBoss")
        else
            GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        end
    elseif msg == "race_btn_3" then
        local open_flag = self.m_model:getRaceTowerOpenByRace(3)
        if open_flag then
            QuickOpenFuncUtil:openFunc({10, 3})
        end
    elseif msg == "race_btn_4" then
        local open_flag = self.m_model:getRaceTowerOpenByRace(4)
        if open_flag then
            QuickOpenFuncUtil:openFunc({10, 4})
        end
    elseif msg == "checkLvUp" then
        self.m_view:lockTouch()
        self:setOnceTimer(0.15, handler(self, self.checkLevelUp))
    elseif msg == "CallDropObjs" then
        if self.m_view.m_battle_node and self.m_view.m_battle_node.playGoldGetSpin then
            self.m_view.m_battle_node:playGoldGetSpin()
        end
    elseif msg == "exc_btn" then
        self:openView("Pops.CommonExclusivePop")
    elseif msg == "close_sync_load_big_loading" then
        self:onSyncEnter()
    elseif msg == "new_user_guide_drama" then
        if UserDataManager.client_data.is_new_user then
            local function callback()
                UserDataManager.client_data.is_new_user = true
            end
            self:openView("Guide.GuideDrama", {dialog_id = 10001, callback = callback})
        end
    elseif msg == "lock_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
    elseif msg == "rpg_map_btn" then
        self:rpgMapReset()
    elseif msg == "open_hero_filter_btn" then
        local function callback(index)
            if self.m_model.m_sel_tab_index == 5 then
                self.m_view.m_cur_tab_node:filter_callback(index)
            end
        end
        self:openView("Pops.HeroFilterPop", {callback = callback})
    elseif msg == "tj_btn" then
        self:openView("HeroBook")
    --elseif msg == "btn_enter" then
    --elseif msg == "btn_exit" then
    --elseif msg == "btn_down" then
    --elseif msg == "btn_up" then
    elseif msg == "formation_callback" then
        self.m_view:closeCallengeSpine()
    elseif msg == "five_line_btn" then
        self:openView("Fivelines")
    elseif msg == "world_map_limit_event_btn" then
        self:openView("WorldMap.WorldMapMain", {auto_open_func = "world_map_events", auto_open_tab_index = 2})
    elseif msg == "sect_build_btn" then
        QuickOpenFuncUtil:openFunc(73)
    elseif msg == "arena_btn" then
        QuickOpenFuncUtil:openFunc(24)
    elseif msg == "treasure_btn" then
        local function netDataCallBack(response)
            if response.finish == 0 and response.cells ~= nil and _G.next(response.cells) ~= nil then
                QuickOpenFuncUtil:openFunc({18, response})
            else
                QuickOpenFuncUtil:openFunc({38, response})
            end
        end
        self.m_model:getNetData("maze_index", nil, netDataCallBack)
    elseif msg == "trial_btn" then
        QuickOpenFuncUtil:openFunc(29)
    elseif msg == "matrix_btn" then
        QuickOpenFuncUtil:openFunc(10)

    elseif msg == "close_battle_loading" then
        self:setOnceTimer(
                0.1,
                function()
                    self:updateMsg("formation_callback", nil, "Loading.BattleLoading")
                end
        )
    elseif msg == "goto_recharge" or msg == "jump_operateActivity" then
        self:openView("OperateActivity", {actives = self.m_model.m_data.recharge_actives, open_id = data})
    elseif msg == "open_seven_day" then
        self:openActivityBtn(23)
    elseif msg == "jump_topup" then
        self:openView("TopUpGiftBag", {actives = self.m_model.m_data.recharge_actives, open_id = data})
    elseif msg == "jump_giftbag" then
        self:openView("GiftBag", {mode = 1, actives = self.m_model.m_data.actives, open_id = data})
    elseif msg == "jump_giftbag2" then
        self:openView("GiftBag", {mode = 1, actives = self.m_model.m_data.actives, active_id = data.active_id})
    elseif msg == "encounter_event_btn" then
        self.m_view:visibleEncounterEventBtn(false)
        self:openView("WorldMap.WorldMapMain", {auto_open_func = "world_map_events", auto_open_tab_index = 3})
    elseif msg == "renshe_btn" then
        self:openView("Xian")
    elseif msg == "tokens_btn" then
        self:openView("Xian")
    elseif msg == "renshe_btn2" then
        self:openView("Xian", {open_npc_guide = true})
    elseif msg == "download_play_btn" then
        self:openView("DownloadWhilePlay")
    elseif msg == "show_a_xian_tips" then
        self:showJieSuoTips()
    elseif msg == "main_quest_auto" then
        self:mainQuestAutoReward(self.m_model.main_quest_auto)
    elseif msg == "pay_test_btn" then
        local charge = ConfigManager:getCfgByName("charge")
        local cfg = charge[1]
        local function rechargeBack(params)
            GameUtil:lookInfoTips(self, {msg = params.payMsg, delay_close = 2})
        end
        PayUtil:rechargeByData(cfg, rechargeBack)
    elseif msg == "show_new_chapter_verse" then
        self.m_view:refreshBattleNode()
        --self.m_view:showChapterVerse()
        --播放动漫
        local stage_cfg = GameUtil:getBattleStageCfg()
        local movie = stage_cfg.movie
        if movie and movie ~= "" then
            self:openView( "Pops.VedioPlayerPop", { vedio_name = movie, no_close_btn = false, close_btn_type = 1})
        end
    elseif msg == "little_games_btn" then --小游戏
        self:openView("LittleGames")
    elseif msg == "frame_visible_status" then
        self.m_view:setFrameVisibleStatus()

    elseif msg == "tianxia_rank_btn" then
        self:openView("TianXiaBattle.TXRankMain")
    elseif msg == "player_back_btn" then
        if UserDataManager.comeback_status == 1 then
            StatisticsUtil:doPointActive(241,0)
            self:openView("PlayerBack.PlayerBackMain")
        elseif UserDataManager.comeback_status == 2 then
            self:openView("PlayerBack.PlayerBackToOld")
        elseif UserDataManager.comeback_status == 4 then
            self:openView("PlayerBack.NewPlayerRegress")
        end
    elseif msg == "open_biggame" then --打开狗头大侠
        self:openView("LittleGames.HelpDog",{stage = "guide",id = data.id})

        --切换侠客和背景
    elseif msg == "hero_switch_btn" then
        self.m_view:showMainUI(false)
        self:openView("Main.SetHeroAndBack", {hero_id = self.m_model.m_set_hero_id, back_img = self.m_model.m_set_back_img})
        --[[
        self.m_model.m_hero_tab_index = self.m_model.m_hero_tab_index + 1
        local hero_list = UserDataManager.hero_data:getHerosId()
        if self.m_model.m_hero_tab_index > #hero_list then
            self.m_model.m_hero_tab_index = 1
        end
        self.m_view:refreshSpine()
        ]]--
    elseif msg == "set_close" then
        self.m_view:showMainUI(true)
        --重新刷新侠客
        local hero_id = UserDataManager.local_data:getUserDataByKey("main_set_hero", 182)
        --if hero_id ~= self.m_model.m_set_hero_id then
            self.m_view:refreshSpine(hero_id)
            self.m_model.m_set_hero_id = hero_id
        --end
        --重新刷新背景
        local back_img = UserDataManager.local_data:getUserDataByKey("main_set_back", "main_bg2")
        --if back_img ~= self.m_model.m_set_back_img then
            self.m_view:refreshBackImg(back_img)
            self.m_model.m_set_back_img = back_img
        --end
    elseif msg == "set_select_hero" then
        self.m_view:refreshSpine(data)
    elseif msg == "set_select_back" then
        self.m_view:refreshBackImg(data)
    --elseif msg == "set_hero" then
    --elseif msg == "set_back" then
    elseif msg == "ad_btn" then
        self:openActivityBtn(self.m_view.m_ad_jump_id)
    --elseif msg == "set_click_carsourel" then
    --    elf:OpenCarouserActivity(data)
    elseif msg == "remove_timer" then
        if self.timer_id then
            self:removeTimer(self.timer_id)
            self.timer_id = nil
        end
    elseif msg == "set_timer" then
        if self.timer_id then
            self:removeTimer(self.timer_id)
            self.timer_id = nil
        end
        self.timer_id = self:setTimer(5,handler(self,self.UpdateCarouselTime))
    end
end

--开启轮播活动快捷入口
function M:openCarouserActivity(open_id)
    if open_id == 295 then -- 巅峰帮会战
        --if data.open_id == 39 then -- 天下
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(192)
        if open_flag == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
            return
        end
        --self:openView("GuildHighWar.GuildHighWarNewMain")
        --self:openView("Main.TotalWorld")
        --self:setOnceTimer(0.3,function()
        --    self:updateMsg("union_war_btn",{is_carousel = true},"Main.TotalWorld")
        --end)
        local function callback(response)
            local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
            if guild_id and guild_id > 0 then
                --有工会
                local function netCallback(response2)
                    --判断活动是否开启
                    local big_stage = response2.big_stage or 0
                    if big_stage <= 0 then
                        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_00102"), delay_close = 2})
                        return
                    end
                    --判断是否为展示期
                    local end_guild_rank = response2.end_guild_rank or nil
                    local end_self_rank = response2.end_self_rank or nil
                    if end_guild_rank and end_self_rank then
                        self:openView("GuildHighWar.GuildHighWarSettIementPop",{end_guild_rank = end_guild_rank,end_self_rank = end_self_rank})
                        return
                    end
                    -- 第一种
                    --self:openView("GuildHighWar.GuildHighWarNewMain",{guild_high_war = response2.guild_high_war})
                    --local ghw_teams = response2.guild_high_war and response2.guild_high_war.teams or {}
                    --UserDataManager:setGuildHighWarTeams(ghw_teams)
                    --第二种
                    self:openView("GuildHighWar.GuildHighWarNewMainYan")
                end
                self.m_model:getNetData("guild_high_war_index",nil,netCallback)
            else
                --没有工会
                self:openView("Union.UnionIndex", response)
            end
        end
        self.m_model:getNetData("guild_index", nil, callback)
    elseif open_id == 441 then
        self:openView("GuildHighWar.GuildHighWarMachineMain") -- 燕过十六州
    end
end

--开启活动功能
function M:openActivityBtn(param)
    local data = 0
    local activity_name = ""
    if type(param) == "number" then
        data = param
    else
        data = param.open_id
        activity_name = param.activity_name
        UserDataManager.m_activity_name = activity_name
    end
    if data == 23 then
        self:openView("GiftBag", {mode = 1, actives = self.m_model.m_data.actives})
    elseif data == 88 then
        local version = UserDataManager:getOpenActiveVersion(88)
        StatisticsUtil:doPointActive(88,version)
        self:openView("OperateActivity", {actives = self.m_model.m_data.recharge_actives})
    elseif data == 74 then
        local version = UserDataManager:getOpenActiveVersion(74)
        StatisticsUtil:doPointActive(74,version)
        audio:SendEvtUI("UI_Questionnaire")
        local tab_data = ConfigManager:getCfgByName("question")
        local question_data = UserDataManager.questions
        local question_cfg = tab_data[question_data.version]
        if SDKUtil.is_no_sdk ~= true and question_cfg and question_cfg.url and question_cfg.url ~= "" then
            local uid = UserDataManager.user_data:getUid()
            local function urlCallback()
                self:updateMsg("common_refresh")
            end
            SDKUtil:openUrl(question_cfg.url .. "&callback_params=" .. uid .. "|" .. question_data.version, urlCallback)
        elseif SDKUtil.is_gmsdk then --是字节的sdk
            local token = UserDataManager.client_data:getSdkToken()
            local role_id = UserDataManager.user_data:getUid()
            local server_id = UserDataManager.server_data:getServerId()
            --local server_id = 1
            local did = ""
            SDKUtil:Getdid(
                    function(params)
                        did = params.data
                        local url =
                        self.m_model.question_url ..
                                "?access_token=" ..
                                token .. "&role_id=" .. role_id .. "&server_id=" .. server_id .. "&did=" .. did
                        SDKUtil:openUrl(
                                url,
                                function(params)
                                    if params ~= nil and params.data ~= nil and params.data == "Webview exit." then
                                        self.webViewExit = true
                                        self:hasQuestion()
                                        self:updateMsg("common_refresh")
                                    end
                                end
                        )
                        self.m_model.question_url = nil

                        self:updateMsg("common_refresh")
                        self:hasQuestion()
                    end
            )
        else
            self:openView("Pops.PSQPop")
        end
    elseif data == 71 then
        local version = UserDataManager:getOpenActiveVersion(71)
        StatisticsUtil:doPointActive(71,version)
        self:openView("GiftBag.TrialPanel")
    elseif data == 76 then
        local version = UserDataManager:getOpenActiveVersion(76)
        StatisticsUtil:doPointActive(76,version)
        audio:SendEvtUI("UI_Online")
        self:openView("GiftBag.OnTimePop")
    elseif data == 78 then
        local version = UserDataManager:getOpenActiveVersion(78)
        StatisticsUtil:doPointActive(78,version)
        self:openView("GiftBag.FirstCharge")
    elseif data == 140 then
        local version = UserDataManager:getOpenActiveVersion(140)
        StatisticsUtil:doPointActive(140,version)
        self:openView("Activities.Voyage.Voyage")
    elseif data == 87 then
        local version = UserDataManager:getOpenActiveVersion(87)
        StatisticsUtil:doPointActive(87,version)
        local push_gifts = self.m_model:getGiftPushs()
        if next(push_gifts) ~= nil then
            self:openView("GiftBag.LimitPop", {push_gift = push_gifts})
        else
            self:updateMsg("common_refresh")
        end
    elseif data == 129 then
        local version = UserDataManager:getOpenActiveVersion(129)
        StatisticsUtil:doPointActive(129,version)
        self:openView("Recharge.EverydayRechargePop")
    elseif data == 121 then
        local version = UserDataManager:getOpenActiveVersion(121)
        StatisticsUtil:doPointActive(121,version)
        self:openView("Summer.SummerMain")
    elseif data == 149 then
        local version = UserDataManager:getOpenActiveVersion(149)
        StatisticsUtil:doPointActive(149,version)
        audio:SendEvtUI("UI_ChongZhi")
        self:openView("TopUpGiftBag", {actives = self.m_model.m_data.recharge_actives})
    elseif data == 118 then
        local version = UserDataManager:getOpenActiveVersion(118)
        StatisticsUtil:doPointActive(118,version)
        self:openView("GiftBag.GiftScrollPanel")
    elseif data == 178 or data == 453 then --开服红包活动
        RedPointUtil:saveLocalRedPointFreshTime(data == 178 and "hong_yun_li_bao" or "qun_ying_li_bao")
        local version = UserDataManager:getOpenActiveVersion(data)
        StatisticsUtil:doPointActive(data,version)
        local url = self.m_model:getRedPaperUrl(data)
        if url ~= nil then
            if url:find("?") then
                url = url.."&"
            else
                url = url.."?"
            end
            local url_new = url.."role_id="..UserDataManager.user_data:getUid().."&server_id="..UserDataManager.server_data:getServerId()
            local callback = function()
                self:updateMsg("common_refresh")
            end
            CS.UnityEngine.Application.OpenURL(url_new)
            --SDKUtil:openUrl(url_new,callback)
        end
    elseif data == 177 then -- 铸剑大会
        local version = UserDataManager:getOpenActiveVersion(177)
        StatisticsUtil:doPointActive(177,version)
        audio:SendEvtUI("UI_ZhuJianDH")
        self.m_model:getNetData("sword_quest_index", {}, function(response)
            if response then
                if response["end"] == 1 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                    for _, itemData in pairs(self.m_model.m_data.actives) do
                        if itemData.open_id == data then
                            itemData.open_status = -1
                            break
                        end
                    end
                    self.m_view:refreshRedPoint()
                    return
                end
                self:openView("CastingSwordMeeting.CastingSwordMain", {open_id = data,response = response})
            end
        end, nil, nil, nil, {forceBack = true})
    elseif data == 221 then    -- 花火大赏
        audio:SendEvtUI("UI_HHDShang_Button")
        self.m_model:getNetData("double_twelve_index", {index = 1}, function(response)
            if response then
                if response["end"] == 1 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                    for _, itemData in pairs(self.m_model.m_data.actives) do
                        if itemData.open_id == data then
                            itemData.open_status = -1
                            break
                        end
                    end
                    self.m_view:refreshRedPoint()
                    return
                end
                self:openView("PetardActivity.PetardMain", {open_id = data,response = response})
            end
        end, nil, nil, nil, {forceBack = true})
    elseif data == 235 then    -- 月影传说
        audio:SendEvtUI("UI_XYCShuo")
        self:openView("MoonShadow.MoonShadowMain")
    elseif data == 226 then     -- 双旦 灵鹿迎新
        audio:SendEvtUI("UI_LLYXin")
        self:openView("DoubleFestivalActivity.DoubleFestivalMain")
    elseif data == 239 then     -- 金山游侠
        audio:SendEvtUI("UI_JSYXia")
        self:openView("Activities.Kingsoft")
    elseif data == 244 then     -- 极阴之塔
        local version = UserDataManager:getOpenActiveVersion(244)
        StatisticsUtil:doPointActive(244,version)
        audio:SendEvtUI("UI_XYCShuo")
        self:openView("YinTower")
    elseif data == 245 then     -- 天机秘境
        local version = UserDataManager:getOpenActiveVersion(245)
        StatisticsUtil:doPointActive(245,version)
        audio:SendEvtUI("UI_XYCShuo")
        self:openView("BudoServer")
    elseif data == 247 then    -- 邪极魅影
        audio:SendEvtUI("UI_XYCShuo")
        self:openView("EvilShadow.EvilShadowMain")
    elseif data > 100000 then -- 三和一礼包
        local group_id = data - 100000
        local push_gifts = self.m_model:getChoiceGiftsByGroup(group_id)
        if next(push_gifts) ~= nil then
            self:openView("GiftBag.ChoiceChargePop", {push_gift = push_gifts})
        else
            self:updateMsg("common_refresh")
        end
    elseif data == 252 then  --龙泉剑影
        audio:SendEvtUI("UI_LQJYing")
        local open_active_data = self.m_model:getOpenActiveData(252)
        self:openView("Dragonsword",{open_active_data = open_active_data})
    elseif data == 261 then
        local version = UserDataManager:getOpenActiveVersion(261)
        StatisticsUtil:doPointActive(261,version)
        audio:SendEvtUI("UI_JHHSui")
        self:openView("GiftBag.CelebrateNewYear", {is_token = false})
    elseif data == 270 then --唐伯虎（类似活动通用）
        local version = UserDataManager:getOpenActiveVersion(270)
        StatisticsUtil:doPointActive(270,version)
        local open_active_data = self.m_model:getOpenActiveData(270)
        self:openView("ActiveCurrent.ActiveCurrentMain",{open_active_data = open_active_data, is_token = false})
    elseif data == 271 then --上元灯会
        local version = UserDataManager:getOpenActiveVersion(271)
        StatisticsUtil:doPointActive(271,version)
        audio:SendEvtUI("UI_HHDShang_Button")
        self:openView("LanternFestival")
    elseif data == 276 then --华山论剑
        audio:SendEvtUI("UI_ZhengFengLJ")
        self:openView("HuashanSword.HuashanSwordMain")
    elseif data == 280 then --古剑奇谭
        audio:SendEvtUI("UI_ZhuJianDH")
        self:openView("GuJianQiTan.GuJianQiTanMain")
    elseif data == 287 then --夺宝奇兵
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(287)
        if open_flag then
            self:openView("HuntTreasuresGuild")
        else
            GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        end
    elseif data == 285 or data == 319 then -- 模拟人生入口
        audio:SendEvtUI("UI_ChaLou")
        self:openView("SimulateLift.SimulateLiftMain", {open_id = data})
    elseif data == 288 then -- 秘境探宝
        local version = UserDataManager:getOpenActiveVersion(288)
        StatisticsUtil:doPointActive(288,version)
        audio:SendEvtUI("UI_HHDShang_Button")
        self:openView("GiftBag.SecretRewardPop")
    elseif data == 264 then
        local function netCallback(response)
            if response then
                if response["end"] == 1 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                    return
                end
                self:openView("Activities.FamilyDinner.FamilyDinner")
            end
        end
        self.m_model:getNetData("spring_festival_enter_check",{open_id = 264},netCallback)
    elseif data == 265 then
        audio:SendEvtUI("UI_HHDShang_Button")
        self:openView("Activities.TinShot.TinShot")
    elseif data == 289 then     -- 花朝佳节
        audio:SendEvtUI("UI_HHDShang_Button")
        self:openView("FlowerFestival.FlowerMain", {open_id = data})
    elseif data == 294 then -- 罗天摘星
        self:openView("WdTower")
    elseif data == 399 then --九尾活动中心
        if NineActiveUtil.icon_click_data and NineActiveUtil.icon_click_data[1] ~= nil then
            local data = NineActiveUtil.icon_click_data[1]
            self:openView("Activities.NineActiveMain.NineActiveMain")
            SDKUtil:openPage(function(params)
                if params ~= nil and params.data ~= nil then
                    UserDataManager.local_data:setLocalDataByKey("windowId",params.data)
                end
            end, data.activityUrl,data.inGameId)
        end
    elseif data == 306 then --通用礼包
        local active_data = UserDataManager:getActivesRechargeDataByOpenId(306)
        if active_data then
            self:openView("PetardActivity.PetardGiftBagNew", {openId = 306,version = active_data.version})
        end
    elseif data == 307 then
        audio:SendEvtUI("UI_HHDShang_Button")
        self:openView("Activities.EnjoySpring",{is_token = false})
    elseif data == 309 then
        self:openView("Activities.FourForceWar",{is_token = false})
    elseif data == 314 then -- 通用抽奖
        local heroDraw = ConfigManager:getCommonValueById(120,0)
        if heroDraw == 1 then
            self:openView("LuckyDraw.HeroDraw")
        else
            self:openView("LuckyDraw.LuckyDraw")
        end
    elseif data == 320 then --武林神话
        audio:SendEvtUI("UI_HHDShang_Button")
        local function netCallback(response)
            if response then
                if response["end"] == 1 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                    return
                end
                if response.big_stage == 8 then
                    self:openView("MythArena.MythArenaShowRank", response)
                else
                    self:openView("MythArena.MythArenaStage", response)
                end
            end
        end
        self.m_model:getNetData("myth_arena_index",nil,netCallback)
    elseif data == 321 then --美味盛宴(美团)
        self:openView("Activities.DeliciousFeast.DeliciousFeastMain")
    elseif data == 332 then --半周年
        audio:SendEvtUI("UI_HHDShang_Button")
        self:openView("HalfAnniversary.HalfAnniversaryMain")
    elseif data == 339 then --小浣熊
        audio:SendEvtUI("UI_XK_JiHuoJM")
        self:openView("Raccon")
    elseif data == 347 then --
        self:openView("Raccon.RacconFinalPop")
    elseif data == 352 then --端午活动
        self:openView("Activities.DragonBoat",{is_token = false})
    elseif data == 363 then --神秘商店
        local function netCallback(response)
            if response.mystery_shop_gift then
                self:openView("SecretStore", response)
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            end
        end
        self.m_model:getNetData("mystery_shop_index",nil,netCallback)
    elseif data == 364 then --武林遗宝
        self:openView("GiftBag.MonthChargePop")
    elseif data == 371 then --华服共赏
        local activeXlsxData = UserDataManager:getActivesRechargeDataByOpenId(371) or {}
        self:openView("FineClothes", {version = activeXlsxData.version})
    elseif data== 366 then --清凉夏日
        self:openView("CoolSummer")
    elseif data == 381 then --赵云壮胆
        self:openView("GiftBag.ZhaoYun")
    elseif data == 380 then --每日限购
        self:openView("DailyPurchaseRestriction")
    elseif data == 373 then --七夕佳节
        self:openView("QiXi.QiXiMain")
    elseif data == 384 then --限时英雄
        self:openView("LimitedHero")
    elseif data == 385 then --三峡五义
        self:openView("ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsMain")
    elseif data == 393 then --侠客行李白
        self:openView("Chivalry.ChivalryMain")
    elseif data == 403 then --风云际会
        self:openView("WindAndCloud.WindAndCloudMain")
    elseif data == 408 then --国色天香
        self:openView("NationalBeautiful.NationalBeautifulMain")
    elseif data == 418 then --周年庆预热
        self:openView("GiftBag.Anniversary")
    elseif data == 427 then --幸运夺宝
        self:openView("LuckyDog.LuckyDogMain")
    elseif data == 419 then --周年庆典
        self:openView("CelebrateOneYear.CelebrateOneYearMain")
    elseif data == 414 then --剑试天下
        local stage
        local actives = {}
        for k,v in pairs(self.m_model.m_data.actives) do
            if v.open_id == 414 then
                stage = v.phase_info.phase or 1
                actives = v or {}
            end
        end
        if stage == 1 or stage == 2 or stage == 8 then  -- 8:展示期
            self:openView("CompareSwordWithWorld.BossFight.BossFightMain")
        elseif stage == 3 or stage == 4 or stage == 5 or stage == 6 then
            self:openView("CompareSwordWithWorld.GameOfHeavenAndEarth")
        elseif stage == 7 then
            self:openView("CompareSwordWithWorld.CompareSwordResult",{active = actives})
        end
    elseif data == 428 then --全民竞猜
        self:openView("Gamble.GambleMain")
    elseif data == 432 then --蓬莱五鬼技能
        self:openView("GhostsOfPengLai/GhostsShowSkill")
    elseif data == 433 then --瑞兔小斋
        self:openView("LuckyRabbitHut.LuckyRabbitHutMain")
    elseif data == 436 then --忠义无双
        self:openView("Loyalty.LoyaltyMain")
    elseif data == 440 then --大富翁
        self:openView("Millionaire.MillionaireMain")
    elseif data == 471 then --江湖情缘
        self:openView("GiftBag.LakesLove", {title_name = activity_name})
    elseif data == 455 then --充值返利
        self:openView("TopUpGiftBag.TopUpRebatePop")
    elseif data == 240 then --赛季预告
        local open_flag, tips_str = self.m_model:checkSeasonPreviewOpen()
        if open_flag then -- 有赛季预告先打开预告，没有再打开赛季旅程
            self:openView("SeasonPreview")
        else
            local open_flag1, tips_str1 = BtnOpenUtil:isBtnOpen(240)
            if open_flag1 then
                self:openView("Achievement") -- 赛季旅程
            else
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str1), delay_close = 2})
            end
        end
    elseif data == 295 or data == 441 then --巅峰帮会战
        self:openCarouserActivity(data)
    elseif data == 474 then
        self:openView("Arena.ArenaRTA.RTAMain")
    else
        QuickOpenFuncUtil:openFunc(data)
    end
end

function M:openStageFormation(params_data)
    local stage_cfg, is_mult = GameUtil:getBattleStageCfg()
    local skip_deploy = stage_cfg.skip_deploy or 0
    if skip_deploy == 1 then -- 需要跳过Formation
        local atk_deployment = UserDataManager.hero_data:getDeploymentByKey("stage")
        local stage_team = UserDataManager.hero_data:getTeamByKey("stage")
        local can_battle = false
        local team = {}
        local hero_id_list = stage_cfg.hero_id_list or {}
        if #hero_id_list > 0 then -- 是否有指定英雄
            for i = 1, 5 do
                local cid = hero_id_list[i] or 0
                if cid == 0 then
                    team[i] = ""
                else
                    local hero_ids = UserDataManager.hero_data:getHeroIdsByCid(cid)
                    team[i] = #hero_ids > 0 and hero_ids[1] or ""
                end
                if team[i] ~= "" then
                    can_battle = true
                end
            end
        else
            for i = 1, 5 do
                team[i] = stage_team[i] or ""
                if team[i] ~= "" then
                    can_battle = true
                end
            end
        end
        if not can_battle then
            self.m_view:closeCallengeSpine()
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0152"), delay_close = 2})
            return
        end
        local function callfunc(response)
            self:openView("GamePanel", {data = response, mode = GlobalConfig.BATTLE_MODE.STAGE})
        end
        self.m_model:getNetData(
                "stage_battle_start2",
                {team = team, deployment = atk_deployment},
                callfunc,
                false,
                nil,
                GlobalConfig.POST
        )
    else
        local cur_mode = nil
        if is_mult then
            cur_mode = GlobalConfig.BATTLE_MODE.MULT_STAGE
        else
            cur_mode = GlobalConfig.BATTLE_MODE.STAGE
        end
        params_data = params_data or {}
        local params = {
            mode = cur_mode,
            new_chapter = params_data.new_chapter,
            back_scene = params_data.scene,
            auto_battle_flag = params_data.auto_battle_flag
        }
        if stage_cfg.prologue_event ~= 0 then
            local function callback()
                if self:hasStoryEffect(stage_cfg) then
                    self:openView("Formation.BeforeStory", params)
                else
                    self:openView("Formation", params)
                end
            end
            self:openView("Guide.GuideDrama", {dialog_id = stage_cfg.prologue_event, callback = callback})
        else
            if self:hasStoryEffect(stage_cfg) then
                self:openView("Formation.BeforeStory", params)
            else
                self:openView("Formation", params)
            end
        end
    end
end

--是否有剧情配置
function M:hasStoryEffect(stage_cfg)
    local level = UserDataManager:getBattleStage()
    local key = "cjq_" .. tostring(level)
    local localData = UserDataManager.local_data:getUserDataByKey(key)
    if localData ~= nil then
        return false
    end
    if stage_cfg.img_event ~= "" then
        return true
    end
    if stage_cfg.scenario_event ~= "" then
        return true
    end
    if stage_cfg.open_event ~= 0 then
        return true
    end
    return false
end

--地图-点击某物件
function M:rpgMapReset(data)
    self:openView("RpgScrollsUI")
end

--购买格子
function M:buySolt()
    local function callfunc(data)
        UserDataManager.extra_hero_grid = data.extra_hero_grid
        self.m_view:updateHero_gz()
    end
    self.m_model:getNetData("hero_buy_hero_grid", nil, callfunc)
end

--计时器
function M:UpdateTime(_, dt)

    local server_time = UserDataManager:getServerTime()
    dt = dt or 0
    -- self.m_model.m_hangup_tim = self.m_model.m_hangup_tim + 1
    -- self.m_model.m_hangup_tim2 = self.m_model.m_hangup_tim2 + 1
    -- self.m_model.on_hook_time = self.m_model.on_hook_time + 1
    -- self.m_model:`heckGetBox()
    -- self.m_view.m_battle_node:switchBoxType(self.m_model.m_hangup_tim)
    if SDKUtil.is_tencent then
        self:TssManage(dt)
    end
    self:tickTestAntiAddiction(dt)
    if self.m_view.m_visibleRefCount > 0 then
        return
    end
    self:rollingManage(dt, server_time)
    self.m_view:updateTime(dt, server_time)
end

function M:tickTestAntiAddiction(dt)
    if UserDataManager.user_data.is_minor then

        self.lastAntiAddiction = self.lastAntiAddiction - dt

        if self.lastAntiAddiction < 0 then
            self.lastAntiAddiction = 60


            -- local curTime = TimeUtil.gmTime(UserDataManager:getServerTime())

            -- if not (curTime.hour == 20 and curTime.min < 58) then
            --     SDKUtil:logOut(
            --         function()
            --             GameMain.reStart()
            --         end
            --     )
            -- else

            --     if  (curTime.hour == 20 and curTime.min > 55) then
            SDKUtil:antiAddiction(
                    0,
                    function(rst)
                        if not rst then
                            SDKUtil:logOut(
                                    function()
                                        GameMain.reStart()
                                    end
                            )
                        end
                    end
            )
            --     end

            -- end
        end
    end
end

function M:showJieSuoTips()
    self.m_view:updateRensheUI()
    self:setOnceTimer(
            3,
            function()
                self.m_view:hideRensheUI()
            end
    )
end

-- tab按钮切换
function M:switchTabBtn(index, first_enter)
    if index == 6 then
        self:openView("Item.ItemList", {isShowRunescapeItem = false})
    else
        if self.m_model.m_sel_tab_index ~= index then
            self.m_view:switchTabNode(index, first_enter)
            self.m_model.m_sel_tab_index = index
            self:closeView("Guide.GuideDialog")
        end
    end
end

function M:moneyFly(data)
    if self.money_fly ~= nil then
        U3DUtil:Destroy(self.money_fly)
    end
    self:updateMsg("checkLvUp")
    --self.money_fly = GameUtil:creatFlyMoney(self.m_view.m_ui_obj, data)
    self.m_model.m_hangup_tim2 = 0
end

function M:openHangReward(index)
    self.m_model.m_hangup_tim = 0
    if self.m_model.m_sel_tab_index == 3 then
        self.m_view.m_cur_tab_node:switchBoxType(self.m_model.m_hangup_tim)
    end

    local function callback(response)
        if index == 1 then
            if self.m_model:checkRewardConsume(response) == true then
                local params = {
                    on_ok_call = function(msg)
                        QuickOpenFuncUtil:openFunc(16)
                    end,
                    new_cancel_call = function(msg)
                        self:openHangRewardPops(index, response)
                    end,
                    tow_close_btn = true,
                    ok_text = Language:getTextByKey("hang_str_0005"),
                    cancel_text = Language:getTextByKey("hang_str_0004"),
                    text = Language:getTextByKey("new_str_0713")
                }
                self:openView("Pops.CommonPop", params)
                return
            else
                self:openHangRewardPops(index, response)
            end
        elseif index == 2 then
            if self.m_model:checkQuickRewardConsume() == true then
                local params = {
                    on_ok_call = function(msg)
                        QuickOpenFuncUtil:openFunc(16)
                    end,
                    new_cancel_call = function(msg)
                        self:openHangRewardPops(index, response)
                    end,
                    tow_close_btn = true,
                    ok_text = Language:getTextByKey("hang_str_0005"),
                    cancel_text = Language:getTextByKey("hang_str_0004"),
                    text = Language:getTextByKey("new_str_0713")
                }
                self:openView("Pops.CommonPop", params)
                return
            else
                self:openHangRewardPops(index, response)
            end
        end
    end
    self.m_model:getNetData("idle_reward_show", nil, callback)
end
function M:onrefreshPrivateRedPoint()
    if not(self.m_model.m_chat_show)  then
        self.m_view:refreshPrivateChatRedPoint()
    end
end
function M:openHangRewardPops(index, response)
    local btn = self.m_view:findGameObject("bag_btn")
    local pos = btn.transform.position
    local params = {
        tim = self.m_model.m_hangup_tim2,
        callback = handler(self, self.getHangReward),
        pos = pos,
        target = btn,
        mode = index,
        resp_data = response
    }
    self:openView("HangReward", params)
end

function M:getHangReward()
    self.m_view:playGetRewardSpine()
end

function M:openViewEvent(event, data)
    local view_name = data.name or ""
    Logger.log("open view : " .. view_name)
    if view_name ~= "Main" and view_name ~= "Loading.SmallLoading" and not self:hasChild("GamePanel") then
        audio:PauseSkillsBusVol()
    end
    if view_name == "Guide.GuideDrama" then
        self.m_view:playOutAnim()
    end
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    Logger.log("close view : " .. view_name)
    if not self:checkHasChild() then
        self.m_view:resetSortOrder()
        LikeOO.OOUIbase:resetViewSortOrder()
        self.m_view:checkHangUpScene()
        self.m_view:resetVisibleView()
        local index = self.m_model.m_sel_tab_index or 1
        if index == 1 then
            audio:ResumeSkillsBusVol()
        end
        SceneManager:getCurSceneModel():setCameraShow(true)
        self.m_view:playCombatUpAnim()
        self.m_view:showChatDetailNode()
        --ResourceUtil:spriteAtlasRealClear()
        --CS.wt.framework.AssetBundleHelper.Inst:UnloadByRefCount();
    end
    if view_name == "Guide.GuideDrama" then
        self.m_view:playEnterAnim()
    elseif view_name == "Chat" then
        self.m_view:refreshChatRedPoint()
    end

end

function M:checkLevelUp()
    self.m_view:unlockTouch()
    local oldLv, curLv = UserDataManager.user_data:getOldLv()
    if curLv > oldLv then
        if SDKUtil.is_gmsdk or SDKUtil.is_oneSDK then
            local getServerData = UserDataManager.server_data:getServerData()
            local user_data = UserDataManager.user_data.user_status
            local params = {
                zoneid = getServerData.ZoneID or "",
                zonename = getServerData.ZoneName or "",
                roleid = user_data.uid or "",
                rolename = user_data.name or "",
                rolelevel = user_data.level or "",
                power = user_data.full_combat or "",
                vip = user_data.vip or "",
                partyid = user_data.guild_id or "",
                partyname = user_data.guild_name or "",
                chapter = UserDataManager:getCurStage() or "",
                serverId = getServerData.server or "",
                serverName = getServerData.server_name or "",
            }
            local json_string = Json.encode(params)
            SDKUtil:RoleLevelUpload(json_string)
        end
        self:openView("Pops.LevelUpPop", {old_lv = oldLv, lv = curLv})
        UserDataManager.user_data:updateOldLv()
    end
end

function M:openNewHero(event, data)
    self.m_view:lockTouch()
    local function pop()
        self.m_view:unlockTouch()
        RewardUtil:rewardTipsByRewards(data)
    end
    self:setOnceTimer(0.2, pop)
end

function M:onApplicationWakeUp(event, data)
    local total_time = data.total_time or 0
    if total_time >= 30 * 60 then
        GameMain.reStart()
    end
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" or curEvent == "equips_update" or curEvent == "mystices_update" then
        --self.m_model:refreshBagListData(self.m_model.m_open_bag_tab_index, true)
        --self.m_view:switchTabForBagNode(self.m_model.m_open_bag_tab_index)
        self.m_view:refreshRedPoint()
    elseif curEvent == "net_data_back" then
        self:updateHeartBeat(data)
    elseif curEvent == "deadline_task_update" then
        self:registerLimitMapEventRefreshTimer()
        self.m_view:refreshBattleNode()
    elseif curEvent == "data_sync_error" then
        self:dataSyncErrorTips()
    elseif curEvent == "rollings_update" then -- 跑马灯数据更新
        for k, v in pairs(data.remove or {}) do
            self.m_rolling[k] = nil
        end
    elseif curEvent == "encounter_update" then
        if UserDataManager.new_ongoing_teams then
            self.m_view:visibleEncounterEventBtn(true)
            UserDataManager.new_ongoing_teams = false
        end
    elseif curEvent == "quest_special_update" or curEvent == "stage_update" then
        self.m_view:updateChapterTask()
    elseif curEvent == "main_team_update" then
        self:setOnceTimer(0.02, function ()
            if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
                SceneManager.curScene:reset()
            end
        end)
    elseif curEvent == "medals_update" then
        self.m_view:updateMedal()
    elseif curEvent == "heros_update" then
        local hero_list = UserDataManager.hero_data:getHerosId()
        if #hero_list > 1 then
            return
        end
        self.m_view:refreshSpine() --第一次获得侠客才刷新
    end
end

function M:screenClickEvent(event, data)
    self:openIdlePopTimer()
end


function M:commonRefreshEvent(event, data)
    self:updateMsg("common_refresh")
end
function M:openIdlePopTimer()
    local idle_time = ConfigManager:getCommonValueById(332, 300)
    idle_time = idle_time < 60 and 300 or idle_time
    local time_dur = EventDispatcher:getTimeDuration(__open_idle_pop_timer)
    if time_dur == -1 then
        EventDispatcher:registerTimeEvent(
                __open_idle_pop_timer,
                function()
                    if not self:hasChild("GamePanel") then
                        self:openView("Pops.IdlePop")
                    end
                end,
                idle_time,
                idle_time
        )
    else
        EventDispatcher:setTimeDuration(__open_idle_pop_timer, idle_time, 0)
    end
end

--- 数据同步错误提示
function M:dataSyncErrorTips()
    local tips = Language:getTextByKey("new_str_0536")
    local params = {
        on_ok_call = function(msg)
            GameMain.reStart()
        end,
        no_close_btn = true,
        text = tips
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

-- 心跳
function M:updateHeartBeat(flag)
    self.m_heart_cd = 60
    if self.m_heart_timer == nil then
        local function heart_tick(_, dt)
            -- Logger.log(self.m_heart_cd,"-------- heart tick --------")
            self.m_heart_cd = self.m_heart_cd - dt
            if self.m_heart_cd <= 0 then
                self.m_heart_cd = 60
                self.m_model:getNetData("user_heartbeat", nil, nil, 0)
            end
        end
        self.m_heart_timer = self:setTimer(1, heart_tick)
    end
end

function M:requestUnion()
    local function callback(response)
        local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
        if guild_id and guild_id > 0 then
            --self:openView("Union.UnionHall", response)
            self:openView("Union.UnionMain", response)
        else
            self:openView("Union.UnionIndex", response)
        end
    end
    self.m_model:getNetData("guild_index", nil, callback)
end

function M:rollingManage(dt, server_time)
    for k, v in pairs(UserDataManager.rollings) do
        if server_time >= v.start_time and server_time <= v.end_time then
            if not self.m_rolling[k] then
                self.m_rolling[k] = 0
            end

            self.m_rolling[k] = self.m_rolling[k] - dt
            if self.m_rolling[k] <= 0 then
                self.m_rolling[k] = v.interval
                if not self.m_rollingTips_View or self.m_rollingTips_View.m_rootView == nil then
                    local rollingTips = CustomRequire("UI.Common.RollingTips")
                    self.m_rollingTips_View = rollingTips.new(self)
                end
                self.m_rollingTips_View:addTips(v.des)
            end
        elseif server_time > v.end_time then
            if self.m_rolling[k] then
                self.m_rolling[k] = nil
            end
        end
    end
end

--主线任务自动领奖
function M:mainQuestAutoReward(data)
    if data and table.nums(data) > 0 then
        self:mainCheckNewHero()
    end
end

function M:mainCheckNewHero()
    local temp_id = 0
    local temp_data = nil
    local new_quest_auto = {}
    for i, v in pairs(self.m_model.main_quest_auto) do
        if temp_id == 0 then
            temp_id = i
            temp_data = v
        else
            new_quest_auto[i] = v
        end
    end
    if self.m_model.main_quest_auto ~= new_quest_auto then
        self.m_model.main_quest_auto = new_quest_auto
    end
    local rewards = RewardUtil:mergeRewardAndFormat(temp_data)
    self:questRewardTipsByRewards(
            temp_id,
            rewards,
            function()
                self:mainQuestAutoReward(self.m_model.main_quest_auto)
            end
    )
end

function M:questRewardTipsByRewards(temp_id, rewards, call_back)
    rewards = rewards or {}
    local index = 1
    local new_reward_indexs = {}
    local function doNextRewardAnim()
        if index > #rewards then
            local reward_count = #rewards
            local show_data = {}
            for i = 1, reward_count do
                local item_reward = rewards[i]
                if new_reward_indexs[i] == nil then
                    table.insert(show_data, item_reward)
                end
            end
            if #show_data > 0 then
                self:openView(
                        "Pops.CommonTaskRewardPop",
                        {quest_id = temp_id, main_quest = show_data, callback = call_back},
                        nil,
                        true
                )
            else
                if call_back then
                    call_back()
                end
            end
        else
            local item_reward = rewards[index] or {}
            index = index + 1
            if item_reward[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS then -- 单独展示
                if UserDataManager.hero_data:isNewHero(item_reward[2]) then
                    UserDataManager.hero_data:removeNewHero(item_reward[2])
                    new_reward_indexs[index - 1] = item_reward
                    self:openView(
                            "HeroInfo.HeroNewPop",
                            {hero_id = item_reward[2], is_new = true, callback = doNextRewardAnim}
                    )
                else
                    doNextRewardAnim()
                end
            elseif item_reward[1] == RewardUtil.REWARD_TYPE_KEYS.ITEM then
                local item = ConfigManager:getCfgByName("item")
                local cfg = item[tonumber(item_reward[2])]
                if cfg.type == 15 then
                    new_reward_indexs[index - 1] = item_reward
                    GameUtil:lookInfoTips(
                            self,
                            {
                                msg = Language:getTextByKey("worldMap_regional_get_item") .. Language:getTextByKey(cfg.name),
                                delay_close = 1,
                                finish = doNextRewardAnim
                            }
                    )
                else
                    doNextRewardAnim()
                end
            else
                doNextRewardAnim()
            end
        end
    end
    doNextRewardAnim()
end

-- 腾讯安全
local TSS_PROC_INTERVAL = 5
local can_tss = true
function M:TssManage(dt)
    --TSS_PROC_INTERVAL = TSS_PROC_INTERVAL - dt
    --if can_tss and TSS_PROC_INTERVAL <= 0 then
    --    can_tss = false
    --    CS.WTTssSDK.TssProc(self.TssDataBack)
    --end
end

function M.TssDataBack(data)
    --Logger.log(data, "tssDataBack data ====")
    if data then
        local url = NetUrl.getUrlForKey("stream")
        NetWorkTss:httpRequest(
                function(recv_data)
                    TSS_PROC_INTERVAL = 5
                    can_tss = true
                    --Logger.log(recv_data,"NetWorkTss back data ===")
                    if recv_data then
                        CS.WTTssSDK.OnRecvMsgToTssClient(recv_data)
                    end
                end,
                url,
                GlobalConfig.POST,
                data,
                "stream"
        )
    else
        TSS_PROC_INTERVAL = 5
        can_tss = true
    end
end

function M:playNextChapter()
    self:openView(
            "Pops.PlotPop",
            {
                callback = function()
                    self.m_view:refreshBattleNode()
                    self.m_view:showChapterVerse()
                end,
                enter_callback = function()
                    self.m_view:checkHangUpScene(true)
                end
            }
    )
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    self:removeTimer(self.m_red_bag_timer_id)
    EventDispatcher:unRegisterEvent("refresh_main_timer")
    EventDispatcher:unRegisterEvent(__open_idle_pop_timer)
    EventDispatcher:unRegisterEvent("limit_map_event_refresh_main_timer")
    EventDispatcher:unRegisterEvent("refresh_all_redpoint_timer")
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_NEW_PRIVATE, {self, self.onrefreshPrivateRedPoint})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_INIT, {self, self.onInitChat})
    EventDispatcher:unRegisterEvent("show_new_hero", {self, self.openNewHero})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.ON_APPLICATION_WAKE_UP, {self, self.onApplicationWakeUp})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.SCREEN_CLICK_EVENT, {self, self.screenClickEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.COMMON_REFRESH, {self, self.commonRefreshEvent})
    M.super.destroy(self)
    ResourceUtil:UnLoadRoleSound("Amb_2D")
end

--刷新主界面聊天内容
--数据走整个聊天管理，不走MODEL
function M:onRefreshChatInfo()
    if self.m_model.m_chat_show then
        local msgs, need_refresh = self.m_model:getChatMsgByChannel(self.m_model.m_cur_channel_id)
        if need_refresh then
            self.m_view:updateChatScroll(msgs)
        end
    end
end

--刷新主界面聊天内容
--数据走整个聊天管理，不走MODEL
function M:onInitChat()
    self.m_view:InitMsg()
end

function M:closePocoManager()
    if GameVersionConfig.Debug == false then
        local gameCenter = U3DUtil:GameObject_Find("GameCenter")
        local pocoManager = gameCenter:GetComponent("PocoManager")
        if not IsNull(pocoManager) then
            pocoManager.enabled = false
        end
    end
end

--获取是否有问卷
function M:hasQuestion()
    if self.m_temp_stage == UserDataManager:getCurStage() and self.webViewExit == false then
        return
    end
    self.webViewExit = false
    self.m_temp_stage = UserDataManager:getCurStage()
    local did = ""
    SDKUtil:Getdid(
            function(params)
                did = params.data
            end
    )
    local params = {
        scene_id = "hall_icon",
        language = "zh_CN",
        platform = 1,
        server_id = UserDataManager.server_data:getServerId(),
        --server_id=1,
        role_id = UserDataManager.user_data:getUid(),
        --role_id=1048599,
        did = did,
        access_token = UserDataManager.client_data:getSdkToken()
        --ingameid=1001,
    }
    NetWork:httpRequest(
            function(params)
                local json = Json.decode(params)
                if json ~= nil and json.data ~= nil and json.data.entries ~= nil and json.data.entries[1] ~= nil then
                    self.m_model.question_url = json.data.entries[1].url
                    self:updateMsg("common_refresh")
                    --else
                    --Logger.logAlways(params)
                end
            end,
            "https://act.nvsgames.cn/v2/entry/list?app_id=6245",
            GlobalConfig.GET,
            params,
            "question",
            1,
            true,
            2,
            true
    ) --正式服链接地址
    --end,"https://act-sandbox.snssdk.com/v2/entry/list?app_id=6245",GlobalConfig.GET,params,"question" ,1,true ,2 ,true) --测试服链接地址
end

--客服红点兜底方式--拉取式获取方式
function M:getCustomerRedPoint()
    local params = {
        open_id = UserDataManager.client_data.openid,
        server_id = UserDataManager.server_data:getServerId(),
        role_id = UserDataManager.user_data:getUid(),
    }
    NetWork:httpRequest(
            function(params)
                local json = Json.decode(params)
                if json ~= nil and json.data ~= nil and json.data.num ~= nil then
                    self.m_view.m_player_attr_node:setCustomerRed(json.data.num > 0)
                end
            end,
            "https://cs.dailygn.com/customer_service/cp/reddot/get?aid=6245",--正式服链接地址
    --"https://cs-sandbox.dailygn.com/customer_service/cp/reddot/get", ----测试服链接地址
            GlobalConfig.GET,
            params,
            "CustomerRedPoint",
            1,
            true,
            2,
            true
    )
end

function M:setNineActive()
    SDKUtil:openFaceVerify(function(params)
        if params ~= nil and params.data ~= nil then
            NineActiveUtil.icon_click_data = params.data
            NineActiveUtil.active_id = "4001"
            self.m_model.nine_active_data = NineActiveUtil:isHasIconData("4001")
            if self.m_model.nine_active_data then
                self:setNineActiveRedPoint()
            end
        end
    end,"icon_click")
end

--设置九尾活动红点
function M:setNineActiveRedPoint()
    if SDKUtil.is_gmsdk and self.m_model.nine_active_data then
        SDKUtil:queryActivityNotifyDataById(function(params)
            if params ~= nil and params.data ~= nil then
                for i, v in ipairs(params.data) do
                    if v.type == 0 then
                        UserDataManager.local_data:setLocalDataByKey("nine_active_4001", 0)
                    else
                        if v.count > 0 then
                            UserDataManager.local_data:setLocalDataByKey("nine_active_4001", 1)
                        end
                    end
                end
            end
        end,self.m_model.nine_active_data.activityId)
    end
end
--轮播 ====================================
function M:UpdateCarouselTime()
    --if self.m_view.move_flag  then return end
    --if self.m_model.m_current_carousel_num <=0 or self.m_model.m_all_carousel_num <= 0 then return end
    --self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num + 1
    --self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num%self.m_model.m_all_carousel_num
    --self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num == 0 and self.m_model.m_all_carousel_num or self.m_model.m_current_carousel_num
    --self.m_view:UpdateCurrentCarouselCell()
    if self.m_view.m_visibleRefCount > 0 then
        return
    end
    self.m_view:updateAD()
end
--轮播 ====================================


-----------------------风云际会
function M:updateRedBagTime()
    local active_data = UserDataManager:getActivesDataByOpenId(407)
    if active_data then
        if not self:checkHasChild() then
            self.m_view:updateRedBagView(true)
            local function netCallback(response)
                if self.m_view then
                    local states = response.status or 0
                    self.m_view:updateRedBagPoint(states)
                end
            end
            local params = {}
            params.open_id = active_data.open_id
            params.vsn = active_data.version
            self.m_model:getNetData("redbag_red_dot", params, netCallback)
        end
    else
        self.m_view:updateRedBagView(false)
        self:removeTimer(self.m_red_bag_timer_id)
    end
end

return M