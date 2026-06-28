local M = class("PubPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Pub.Guide"
    audio:SendEvtUI("Amb_2D_flag_lantern")
    audio:SendEvtBGM("Set_State_ShiWu02")
    self.tenGachaCanClick = true;
    self.oneGachaCanClick = true;
    EventDispatcher:registerEvent("subscribe_buy_event", {self, self.eventHandle})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    --toggle4 倒计时
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:startGuide()
    --第一个引导 招募单抽
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(27, 1)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
    --第二个引导 前缘招募
    --[[
    local __guide_cfg = ConfigManager:getCfgByName("guide")
    local cfg = __guide_cfg[50001]
    local stage = cfg.trigger[2]
    local map_id = UserDataManager:getBattleStage()
    if map_id ~= stage then
        return
    end
    have_guide = UserDataManager.guide_data:setAnyTeamGuide(50, 1)
    --self.m_is_guide50 = have_guide
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
    ]]--
end

function M:eventHandle(msg, data)
    if msg == "subscribe_buy_event" then
        self.m_view:refreshUI()
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 9})
    elseif msg == "toggle1" then
        self:switchToggle(1)
    elseif msg == "toggle2" then
        self:switchToggle(2)
    elseif msg == "toggle3" then
        self:switchToggle(3)
    elseif msg == "toggle4" then
        self:switchToggle(4)
    elseif msg == "switch_toggle" then
        self:switchToggle(data)
        --[[
    elseif msg == "right_btn" or msg == "Sliding_left" then
        if self.m_model.m_lock_change then
            return
        end
        local index = self.m_model.m_index + 1
        if index > 3 then
            index = 1
        end
        self.m_model:setSelectIndex(index)
        self.m_view:refreshUI()
        self.m_view:changeGacha()
        self:updateMsg("close_gift_btn")
    elseif msg == "left_btn" or msg == "Sliding_right" then
        if self.m_model.m_lock_change then
            return
        end
        local index = self.m_model.m_index - 1
        if index < 1 then
            index = 3
        end
        self.m_model:setSelectIndex(index)
        self.m_view:refreshUI()
        self.m_view:changeGacha()
        self:updateMsg("close_gift_btn")
        ]]--
    elseif msg == "one_gacha_btn" then
        if self.oneGachaCanClick == true then
            self:toGacha(true, self.m_view.one_gacha_times)
            self.oneGachaCanClick = false;
            self:setOnceTimer(2, function()
                self.oneGachaCanClick = true;
            end)
        end
        --self:openView("HeroInfo.HeroNewPop", {hero_id = 311, is_new = true})
    elseif msg == "one_gacha_again" then
        if self.oneGachaCanClick == true then
            self:toGacha(true, data or 0, true)
            self.oneGachaCanClick = false;
            self:setOnceTimer(2, function()
                self.oneGachaCanClick = true;
            end)
        end
    elseif msg == "ten_gacha_btn" then
        if self.tenGachaCanClick == true then
            self:toGacha(false, self.m_view.gacha_times)
            self.tenGachaCanClick = false;
            self:setOnceTimer(2, function()
                self.tenGachaCanClick = true;
            end)
        end
    elseif msg == "ten_gacha_again" then
        if self.tenGachaCanClick == true then
            self:toGacha(false, data or 0, true)
            self.tenGachaCanClick = false;
            self:setOnceTimer(2, function()
                self.tenGachaCanClick = true;
            end)
        end
    elseif msg == "get_mast_hero_btn" then
            --点击领取
        self.m_model:getNetData("gacha_receive_bless_hero",nil, function( response )
            --Logger.logError(response," 领取返回数据 ")
            --只有第一次会弹出这个
            if response.need_alert ~= nil and _G.next(response.need_alert) ~= nil then
                local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
                local cfg = card_hero_cfg[response.need_alert[1]]
                self:openView("HeroInfo.HeroNewPop", {hero_id = cfg.hero_id, is_new = true})
            else
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_model:updateBlessData(response)
            self.m_view:refreshUI()
        end)
    elseif msg == "wish_help_btn" then
        local params = {
            title = Language:getTextByKey("tid#luky1"),
            content = Language:getTextByKey("tid#luky2"),
        }
        self:openView("Pops.CommonFiveLineHelpPop", params)
    elseif msg == "race_help_btn" then
        local params = {
            title = Language:getTextByKey("tid#wish1"),
            content = Language:getTextByKey("tid#wish2"),
        }
        self:openView("Pops.CommonFiveLineHelpPop", params)
    elseif msg == "index_change" then
        self.m_model:setSelectIndex(data)
        self.m_view:refreshUI()
        self.m_view:changeGacha()
        self:updateMsg("close_gift_btn")
    elseif msg == "wish_btn" then
        self:openView("Pub.WishPop",{data = self.m_model.m_data.hero_wish_list})
        self.m_view:closeWishFiger()
    elseif msg == "card_btn" then
        self:openView("Pub.MartialGachaPop", {item_id = ConfigManager:getCommonValueById(44)[1]})
    elseif msg == "picker_btn" then
        local params = {}
        params.martial = self.m_model.m_race
        --params.openMartial = self.m_model.m_data.today_can_get_race
        params.end_ts = self.m_model.m_data.today_end_ts
        params.callback = function(data)
            if data then
                self.m_model:updateData(data)
                self.m_view:refreshUI()
            end
        end
        self:openView("Pub.MartialSelectPop", params)
    elseif msg == "reward_tips_btn" then
        self.m_view:showGiftTips()
    elseif msg == "gift_btn" then
        self:getBoxRewards()
    elseif msg == "close_gift_btn" then
        self.m_view:closeGift()
    elseif msg == "wish_hero_btn" then
        audio:SendEvtUI("Play_UI_Popup_3")
        --local unlock_normal_time = ConfigManager:getCommonValueById(427);
        --if self.m_model.m_bless_data.normal_times < unlock_normal_time then
        --    local time = unlock_normal_time - self.m_model.m_bless_data.normal_times;
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0035", time), delay_close = 2})
        --else
            self:openView("Pub.WishMustPop",{ data = self.m_model.m_bless_data })
        --end
    elseif msg == "gaChabtnSearch2" then
        self:openView("Pops.HeroLookInfo", {hero_id = 412, is_new = false})
    elseif msg == "update_bless_hero" then
        self.m_model:update_bless_hero( data );
        self.m_model:updateMaxValue();
        self.m_view:refreshZhuFu();
        self.m_view:updateZhuFuValue(self.m_model.m_bless_data.bless_value)
        self.m_view:UpdateXinYuanDanByIndex(2);
    elseif msg == "update_hero_wish_list" then
        self.m_model:update_hero_wish_list( data );
        self.m_view:refreshXinYuan();
    elseif msg == "wish_race_heros_btn" then
        audio:SendEvtUI("Play_UI_Popup_3")
        self:openView("Pub.WishRaceHerosPop",{ data = self.m_model.m_bless_data,time = self.m_model.week_etime } )
    elseif msg == "update_data" then
        self.m_model:updateData(data)
        self.m_view:refreshUI()
    elseif msg == "time_end" then
        self:updateRequestIndexData()
    elseif msg == "help_btn" then
        self:openView("Pub.GachaHelpPop", {pool_id = self.m_model.m_pool_id})
    elseif msg == "check_guide" then
        self.m_guide:checkGuide()
    elseif msg == "show_reward" then
        --self.m_view:sliderAction()
        if next(self.m_model.m_show_reward) then
            RewardUtil:rewardTipsByData(self.m_model.m_show_reward, nil,nil,{fly = false, fly_target = "shop_btn", target_control = self, tips_up = "Pub_str_0032"})
            self.m_model.m_show_reward = {}
        end
    elseif msg == "shop_btn" then
        self:openView("Shop", { shop_type = 3})
    elseif msg == "privilege_btn" then -- 特权按钮
        local params = {top = true}
        params.click_transform = self.m_view:findGameObject("privilege_detail").transform
        --params.click_transform = self.m_view:findGameObject("privilege_btn").transform
        local cfg = ConfigManager:getCfgByName("auto_subscribe")
        params.title = cfg[2].name
        if UserDataManager:hasGachaSubscribe() then
            params.status_text = "bounty_str_0019"
            params.msg = cfg[2].des
        else
            params.msg = Language:getTextByKey("bounty_str_0020")
            params.btn_text = "new_str_0801"
            params.fh_num = self.m_model:getSubDiamond()
            params.callback = function()
                QuickOpenFuncUtil:openFunc(10038)
            end
        end
        GameUtil:lookInfoTips(self.m_control, params)
    elseif msg == "add_total_btn" then -- 累计元宝按钮
        local params = {top = true}
        params.click_transform = self.m_view:findGameObject("add_total_btn").transform
        local cfg = ConfigManager:getCfgByName("auto_subscribe")
        params.title = cfg[2].name
        params.msg = Language:getTextByKey("gf_str_0112")
        if UserDataManager:hasGachaSubscribe() then
            --params.status_text = "bounty_str_0018"
        else
            params.btn_text = "new_str_0801"
            params.callback = function()
                QuickOpenFuncUtil:openFunc(10038)
            end
        end
        GameUtil:lookInfoTips(self.m_control, params)
    elseif msg == "race_btn_1" then
        self:checkoutMartialHandle(1)
    elseif msg == "race_btn_2" then
        self:checkoutMartialHandle(2)
    elseif msg == "race_btn_3" then
        self:checkoutMartialHandle(3)
    elseif msg == "race_btn_4" then
        self:checkoutMartialHandle(4)
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "skip_anim_btn" then
        self.m_model:changeSkipAnimFlag()
        self.m_view:updateSkipAnimStatus()
    elseif msg == "score_btn" then
        self:openView("Pub.GachaScorePop", { value = self.m_model.m_score, consume = self.m_model.m_score_consume })
    elseif msg == "score_gacha" then
        self:gachaRequestForScore()
    end
end

function M:switchToggle(index)
    if self.m_model.m_lock_change then
        return
    end
    if index == 4 then
        self:openView("Predestined")
    end
    self.m_model:setSelectIndex(index)
    self.m_view:refreshUI()
    self.m_view:changeGacha()
    self:updateMsg("close_gift_btn")

end

function M:checkoutMartialHandle(index)
    --local martial_tab = ConfigManager:getCommonValueById(34)
    local martial_tab = {3,4,5,6}
    local martail = martial_tab[index]
    if martail ~= self.m_model.m_race then
        local function checkoutCallback(response)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        local params = {}
        params.target_race = martail
        self.m_model:getNetData("gacha_checkout_cur_gacha_race", params, checkoutCallback)
    end
end

function M:updateRequestIndexData()
    local function indexCallback(response)
        -- Logger.log(response,"indexCallback response=====")
        self.m_model:updateData(response)
        self.m_view:refreshUI()

        local params = {}
        params.martial = self.m_model.m_race
        params.openMartial = self.m_model.m_data.today_can_get_race
        params.end_ts = self.m_model.m_data.today_end_ts
        self:updateMsg("time_end", params, "Pub.MartialSelectPop")
    end
    self.m_model:getNetData("gacha_index", nil, indexCallback)
end

function M:getBoxRewards()
    if self.m_model:canReceiveRewards() then
        local function Callback(response)
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateChestRewards(response)
            self.m_view:refreshUI()
        end
        local params = {}
        params.chest_type = self.m_model.m_index
        self.m_model:getNetData("gacha_receive_chest_reward", params, Callback)
    else
        self.m_view:showGift()
    end
end

function M:toGacha(is_once,timesParam, again)
    if self.m_model:isMaxTime() then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
        return
    end
    if timesParam == 0 then
        if self.m_model.m_index == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0028"), delay_close = 2})
        elseif self.m_model.m_index == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0029"), delay_close = 2})
        elseif self.m_model.m_index == 3 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0016"), delay_close = 2})
        end
        return
    elseif timesParam == 10 then
        UserDataManager.local_data:setUserDataByKey("gacha_ten", 1)
    elseif not is_once then
        if self.m_model.m_index == 2 then -- 用砖石补招募令
            local buy_num = 10 - timesParam
            local price = ConfigManager:getCommonValueById(319, 200)
            if UserDataManager:hasGachaSubscribe() then
                price = ConfigManager:getCommonValueById(379, 200)
            end
            local diamond_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 1})
            local item_data =  RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, 1009, 1})
            local params =
            {
                on_ok_call = function(msg)
                    local diamond_num = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
                    if diamond_num < price*buy_num then
                        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0029"), delay_close = 2})
                    else
                        self:gachaRequest(10, again, is_once)
                    end
                end,
                text = string.format(Language:getTextByKey("Pub_str_0030"),buy_num*price,diamond_data.name, buy_num, item_data.name)
            }
            self:openView("Pops.CommonPop", params)
            return
        end
    end
    self:gachaRequest(timesParam, again, is_once)
end

function M:gachaRacehandle(timesParam, again, is_once)
    if self.m_model.m_index == 3 and not again then -- 打开选择种族界面
        local params = {}
        params.martial = self.m_model.m_race
        params.end_ts = self.m_model.m_data.today_end_ts
        params.callback = function(data)
            if data then
                self.m_model:updateData(data)
                self.m_view:refreshUI()
            end
            self:gachaRequest(timesParam, again, is_once)
        end
        self:openView("Pub.MartialSelectPop", params)
    else
        self:gachaRequest(timesParam, again, is_once)
    end
end

function M:gachaRequest(timesParam, again, is_once)
    self.m_view:lockTouch("gachaRequest")
    --local gacha = ConfigManager:getCfgByName("gacha")[self.m_model.m_pool_id]
    local params = {}
    params.pool_id = self.m_model.m_pool_id
    params.gacha_type = timesParam
    local function gachaCallback(response)
        UserDataManager.hero_data:cleanNewHero()
        --local function delayTimeClose()
        --    self:closeView("Pub.GachaOnePop")
        --    self:closeView("Pub.GachaTenPop")
        --end
        --self:setOnceTimer(0.5, delayTimeClose)
        if response then
            self.m_model:updateBlessData(response)
            self.m_model:mergeReward(response.chest_reward)
            self.m_model:mergeReward(response.resolve_reward)
            local count = #response.hero_show
            self.m_model:updateData(response.gacha_data)
            self.m_model.m_score = response.integral
            self.m_view:refreshUI()
            if again or self.m_model.m_skip_anim_flag then
                self:closeView("Pub.GachaOnePop")
                self:closeView("Pub.GachaTenPop")
                if not is_once then
                    self:openView("Pub.GachaTenPop",{cards = response.hero_show, new_card = response.need_alert, pool_id = self.m_model.m_pool_id, type_index = self.m_model.m_index})
                else
                    self:openView("Pub.GachaOnePop",{cards = response.hero_show, new_card = response.need_alert, pool_id = self.m_model.m_pool_id, type_index = self.m_model.m_index})
                end
                self.m_view:unlockTouch("gachaRequest 3")
            else
                self:gachaVedio(response, is_once)
            end
        else
            self:closeView("Pub.GachaOnePop")
            self:closeView("Pub.GachaTenPop")
            self:updateMsg("show_reward")
            self.m_view:unlockTouch("gachaRequest 2")
        end
    end
    self.m_model:getNetData("gacha_get_gacha", params, gachaCallback, nil, true)
end

function M:gachaRequestForScore()
    self.m_view:lockTouch("gachaRequest")
    local params = {}
    params.pool_id = GlobalConfig.GACHA_SCORE_ID
    params.gacha_type = 1
    local function gachaCallback(response)
        UserDataManager.hero_data:cleanNewHero()
        if response then
            self.m_model:updateBlessData(response)
            self.m_model:mergeReward(response.chest_reward)
            self.m_model:mergeReward(response.resolve_reward)
            local count = #response.hero_show
            self.m_model:updateData(response.gacha_data)
            self.m_model.m_score = response.integral
            self:updateMsg("refresh", response.integral, "Pub.GachaScorePop")
            self.m_view:refreshUI()
            if self.m_model.m_skip_anim_flag then
                self:closeView("Pub.GachaOnePop")
                self:closeView("Pub.GachaTenPop")
                self:openView("Pub.GachaOnePop",{cards = response.hero_show, new_card = response.need_alert, pool_id = GlobalConfig.GACHA_SCORE_ID, type_index = 5})
                self.m_view:unlockTouch("gachaRequest 3")
            else
                self:gachaVedio(response, true, 5)
            end

        else
            self:closeView("Pub.GachaOnePop")
            self:closeView("Pub.GachaTenPop")
            self:updateMsg("show_reward")
            self.m_view:unlockTouch("gachaRequest 2")
        end
    end
    self.m_model:getNetData("gacha_get_gacha", params, gachaCallback, nil, true)
end

function M:gachaVedio(response, is_once, type)
    audio:PauseMusicBusVol()
    local gacha_sound = "Gacha_Long"
    local vedio_name = UserDataManager.local_data:getUserDataByKey("gacha_vedio", "gacha")
    if vedio_name == "gacha" then
        UserDataManager.local_data:setUserDataByKey("gacha_vedio", "gacha_short")
    else
        gacha_sound = "Gacha_Short"
    end
    local gacha_sound = audio:SendEvtUI(gacha_sound)
    self:openView("Pops.VedioPlayerPop", {callback = function()
        audio:ResumeMusicBusVol()
        audio:StopPlayingID(gacha_sound)
        if not is_once then
            self:openView("Pub.GachaTenPop",{cards = response.hero_show, new_card = response.need_alert, pool_id = self.m_model.m_pool_id, type_index = self.m_model.m_index})
        else
            self:openView("Pub.GachaOnePop",{cards = response.hero_show, new_card = response.need_alert, pool_id = self.m_model.m_pool_id, type_index = type or self.m_model.m_index})
        end
        self.m_view:unlockTouch("gachaRequest 1")
    end, vedio_name = vedio_name .. ".mp4", no_close_btn = false, close_btn_type = 1})
end

function M:dataUpdateEvent(event, data)
    if data.event == "remove_red_dot" or data.event == "red_dot_update" then
        self.m_view:refreshRedPoint()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("subscribe_buy_event", {self, self.eventHandle})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    audio:SendEvtBGM("Set_State_ShiWu01")
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
