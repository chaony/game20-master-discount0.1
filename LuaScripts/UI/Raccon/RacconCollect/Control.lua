local M = class("RacconCollectControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint", nil, "Raccon")
        self:closeView()
    elseif msg =="tab_btn1" then
        audio:SendEvtUI("UI_Tab_N3")
        self.m_model:setTabIndex(1)
        self.m_view:updateBtnStatus()
        self.m_view:updateLoopScroll()
    elseif msg =="tab_btn2" then
        audio:SendEvtUI("UI_Tab_N3")
        self.m_model:setTabIndex(2)
        self.m_view:updateBtnStatus()
        self.m_view:updateLoopScroll()
    elseif msg == "detail_reward_btn" then
        self:questRewardTaskDetail(data)
    elseif msg == "detail_goto_btn" then
        audio:SendEvtUI("Play_UI_NormalClick")
        local go_type = data.go_type or {}
        if go_type == 10052 then
            self:updateMsg("fctj_btn", nil, "Raccon")
        elseif go_type == 10051 then
            QuickOpenFuncUtil:openFunc(go_type)
        else
            static_rootControl:closeAllViewPop()
            QuickOpenFuncUtil:openFunc(go_type)
        end
        self:updateMsg(99999)
    elseif msg == "zhuanji_item" then
       self:touchZhuanjiItem(data)
        audio:SendEvtUI("UI_Popup_N2")
    elseif msg == "box_click" then
        audio:SendEvtUI("Play_UI_TresureChest")
        local rewards = data.data.cfg.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
    elseif msg == "game_btn" then
        self:openView("Raccon.RacconTinShot", {pop_from_func_id = -1})
        self:closeView()
    elseif msg == "exchange_btn" then
        if self.m_model.main_gacha_cfg.jump > 0 then
            QuickOpenFuncUtil:openFunc(self.m_model.main_gacha_cfg.jump)
            self:closeAllViewPop()
        end
    elseif msg == "gift_btn" then
        self.m_view:showClickTx()
        self:getCardReward()
    elseif msg == "xkz_btn" then
        self:openView("Raccon.RacconXkz", {pop_from_func_id = -1})
        self:closeView()
    elseif msg == "look_btn" then
        self:openView("Raccon.RacconTinShotRewardPreview", {open_type = "collect", version = self.m_model.m_version})
    elseif msg == "help_btn" then
        local params = {}
        params.title = "raccon_text_0002"
        local content = self.m_model:getMainCfgVByK("raccoon_des") or "tid#XiaoHuanXiongDes_5"
        params.content = content
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:questRewardTaskDetail(data)
    local function netCallback(response)
        if response then
            self.m_model:setTaskDetailCfgData(response.quests)
            self.m_view:refreshUI()
            --self.m_model:updateRewardBoxDataScore(response.score)
            --self.m_model:updateRewardBoxData()
            --self.m_view:updateRewardBox()
            --self.m_view:updateZhuanjiLoopScroll()
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
        end
    end
    local params = {}
    params.open_id = 344
    params.vsn = self.m_model:getVersion()
    params.quest_id = data.quest_id
    self.m_model:getNetData("common_quest_recv_task", params, netCallback)
end

function M:touchZhuanjiItem(data)
    if data.day <= self.m_model:getCurrentDay() and data.day ~= self.m_model:getCurrentDayUpdate() then
        self.m_model:setCurrentDayUpdate(data.day)
        self.m_view:refreshUI()
    end
end

function M:questRewardBox(data)
    local function netCallback(response)
        self.m_model:updateRewardBoxDataScoreDone(response.score_done)
        self.m_model:updateRewardBoxData()
        self.m_view:updateRewardBox()
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {}
    params.version = self.m_model:getVersion()
    params.score_id = data.id
    self.m_model:getNetData("hero_event_recv_score_reward", params, netCallback)
end

function M:getCardReward(data)
    local function netCallback(response)
        if response and response.reward then
            self.m_view:playFlyAnim(response.reward)
        end
    end
    local params = {}
    params.open_id = self.m_model.open_id
    params.vsn = self.m_model.m_version
    self.m_model:getNetData("active_common_quest_card", params, netCallback)
end


function M:showHeroInfo()
    self:closeView("Pops.HeroLookInfo",nil, false)
    self:openView("Pops.HeroLookInfo", {hero_id = self.m_model.m_hero_skin_data.hero, is_new = false})
end

return M
