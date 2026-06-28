local M = class("OptionsPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "update_hero_list" then
        self.m_model:updateTeamData()
        self.m_view:updateListScroll()
    elseif msg == "back_btn" then
        self:closeView()
    elseif msg == "tab_btn" then
        self.m_model:setTab(data)
        self.m_view:refreshUI()
    elseif msg == "music_value" then
        self.m_model:setMusicVolume(data)
        self.m_view:setMusicValue()
    elseif msg == "effic_value" then
        self.m_model:setEffectVolume(data)
        self.m_view:setEffectValue()
    elseif msg == "voice_value" then
        self.m_model:setCVVolume(data)
        self.m_view:setVoiceValue()
    elseif msg == "player_icon_btn" then
        self:openView("Options.OptionsHeadPop")
        -- GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0306"), delay_close = 2})
    elseif msg == "sex_btn" then
        self.m_view:showSexBtn(true)
    elseif msg == "close_sex_btn" then
        self.m_view:showSexBtn(false)
    elseif msg == "boy_btn" then
        self.m_model:setSex(1)
        self.m_view:showSexBtn(false)
    elseif msg == "girl_btn" then
        self.m_model:setSex(2)
        self.m_view:showSexBtn(false)
    elseif msg == "team_btn" then
        -- self.m_view:showTeamPanel(true)
    elseif msg == "team_save_btn" then
        self.m_view:showTeamPanel(false)
    elseif msg == "click_hero" then
        self.m_model:setTeamData(data)
        self.m_view:refreshUI()
    elseif msg == "select_server_btn" then
        self:openView("Options.OptionsServerPop")
    elseif msg == "renamed_btn" then
        self:openEditName()
    elseif msg == "signatrue_btn" then
        self:openEditSignatrue()
    elseif msg == "copy_uid_btn" then
        CS.UnityEngine.GUIUtility.systemCopyBuffer = UserDataManager.user_data:getUserStatusDataByKey("uid")
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0698"), delay_close = 2})
    elseif msg == "cdkey_btn" then
        self:openEditCDkey()
        --CS.wt.framework.ResourcesHelper.UnLoadMemeroy();
    elseif msg == "click_effect_btn" then
        self.m_model:setClickEffect()
        self.m_view:updateClickEffectBtn()
    elseif msg == "account_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0306"), delay_close = 2})
    elseif msg == "community_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0306"), delay_close = 2})
    elseif msg == "airlines_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0306"), delay_close = 2})
    elseif msg == "channel_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0306"), delay_close = 2})
    elseif msg == "quality_btn" then
        self.m_model:setGameQuality(data)
    elseif msg == "sign_end" then
        --self:requestSign()
    elseif msg == "refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "debug_btn" then
        self.m_model.debug_click_count = self.m_model.debug_click_count or 0
        self.m_model.debug_click_count = self.m_model.debug_click_count + 1
        if self.m_model.debug_click_count == 10 and CS.LuaGameLaunch.Instance.OpenSRDebug then
            CS.LuaGameLaunch.Instance:OpenSRDebug()
            --GameVersionConfig.OpenPlayDataShow = true;
        end
        if self.m_model.debug_click_count == 5 then
            CS.LuaGameLaunch.Instance.showOnGUIFlag = not CS.LuaGameLaunch.Instance.showOnGUIFlag
            ResourceUtil:luaGCStep(1024*1024)
            ResourceUtil:printLuaTotalMem()
            ResourceUtil:printMonoTotalMem()
        end
    elseif msg == "restart_btn" then

        if SDKUtil.is_oneSDK then
            SDKUtil:logOut(handler(self, function()
                GameMain.reStart()
            end))

        else
            GameMain.reStart()
        end
    elseif msg == "setting_btn" then
        self:openView("Options.OptionsSettingPop")
    elseif msg == "customerService_btn" then --客服
        local url = string.format("https://cs.dailygn.com?role_id=%s&server_id=%s",self.m_model.m_data.user.uid,UserDataManager.server_data:getServerId()) --正式环境
        --local url = string.format("https://cs-sandbox.dailygn.com?role_id=%s&server_id=%s",self.m_model.m_data.user.uid,UserDataManager.server_data:getServerId()) --沙箱环境
        SDKUtil:openUrl(url,function()
            self.m_model:getNetData("user_heartbeat", nil, nil, 0)
            local red = RedPointUtil:hasRedPointById(142)
            if red == self.m_model.red_point then
                self:getCustomerRedPoint()
            end
            self.m_view:customerServiceHasRedPoint() --刷新客服红点
        end)
    elseif msg == "hide_btn" then --隐私协议
        if SDKUtil.sdk_params.fchannel == "yyh" then
            CS.UnityEngine.Application.OpenURL("http://api.one-fast.net/view/xieyi/privacy_policy.html")
        else
            CS.UnityEngine.Application.OpenURL("https://ycimg-m.duoku.com/cimages/img/promo/source/pages/gamesite/privacy_jxjh.html")
        end
    elseif msg == "user_btn" then --用户协议
        if SDKUtil.sdk_params.fchannel == "yyh" then
            CS.UnityEngine.Application.OpenURL("http://api.one-fast.net/view/xieyi/user_agreement.html")
        else
            CS.UnityEngine.Application.OpenURL("https://ycimg-m.duoku.com/cimages/img/promo/source/pages/gamesite/user_jxjh.html")
        end
    elseif msg == "tokens_btn" then
        self:openView("TopUpGiftBag.ToKensEntrancPop")
    elseif msg == "btn_flowerBtn" then
        local activityData = UserDataManager:getActivesDataByOpenId(291)
        if not activityData then
            return
        end
        self:openView("FlowerFestival.FlowerGiveRank",{version = activityData.version})
    elseif msg == "hero_setting_btn" then
        local hero_count = 0
        local hero_count_tab = {}
        local hero_data = UserDataManager.hero_data:getHerosData() or {}
        for k, v in pairs(hero_data) do
            hero_count_tab[v.id] = v
        end
        for k, v in pairs(hero_count_tab) do
            hero_count = hero_count + 1
        end
        
        if hero_count >= 5 then
            self:openView("Options.OptionsHeroSet",{slot_hero_data = self.m_model.m_team_hero_data} )
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gua_ji_xia_ke_str_004"), delay_close = 2})
        end
        
        
    end
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
                    self.m_view:settingCustomerRedPoint(json.data.num > 0)
                end
            end,
            "https://cs.dailygn.com/customer_service/cp/reddot/get?aid=6245",
            GlobalConfig.GET,
            params,
            "CustomerRedPoint",
            1,
            true,
            2,
            true
    ) --正式服链接地址
    --https://cs-sandbox.dailygn.com/customer_service/cp/reddot/get  沙箱环境链接地址
end

function M:openEditName()
    local cost = ConfigManager:getSystemCostValueById(2)
	local user_data = UserDataManager.user_data
	local name = user_data:getUserStatusDataByKey("name")
    Logger.log(UserDataManager.is_first_name, "UserDataManager.is_first_name ==")
    local is_free = UserDataManager.is_first_name == 0
    local params =
    {
        on_ok_call = function(msg)
            self:requestSetName(msg)
        end,
        is_free = is_free,
        cost = cost[1] or {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,999999},
        tips = Language:getTextByKey("options_str_0003"),
        title = Language:getTextByKey("options_str_0004"),
        --placeholder = Language:getTextByKey("options_str_0003"),
        text = name,
        popType = 1,
    }
    static_rootControl:openView("Pops.CommonInputPop", params)
end

function M:openEditSignatrue()
    local sign_desc = self.m_model:getSginDesc()
    local params =
    {
        on_ok_call = function(msg)
            self:requestSign(msg)
        end,
        title = Language:getTextByKey("options_str_0025"),
        --placeholder = Language:getTextByKey("options_str_0028"),
        text = sign_desc,
    }
    static_rootControl:openView("Pops.CommonInputBigPop", params)
end

function M:openEditCDkey()
	local params =
    {
        on_ok_call = function(msg)
            self:requestCDKey(msg)
        end,
        title = Language:getTextByKey("options_str_0005"),
        placeholder = Language:getTextByKey("options_str_0006"),
        character_limit = 24,
    }
    static_rootControl:openView("Pops.CommonInputPop", params)
end

function M:requestSetName(msg)
    local function nameCallback(response)
        UserDataManager:setIsFirstName(response.is_first_name)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0007"), delay_close = 2})
        self.m_view:refreshUI()
    end
    local params = {}
    params.name = msg
    self.m_model:getNetData("user_set_name", params, nameCallback)
end

function M:requestCDKey(data)
    if data == nil or data == "" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0008"), delay_close = 2})
        return
    end
    local function nameCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {}
    params.code = data
    self.m_model:getNetData("code_use_code", params, nameCallback)
end

function M:requestSign(m_msg)
    local desc = m_msg
    if desc == self.m_model.m_data.user.desc then return end
    local function signCallback(response, tag, status_code)
        if response then
            self.m_model.m_data.user.desc = desc
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0462"), delay_close = 2})
            self.m_view:setSignText(desc)
        else
            if status_code == GlobalConfig.SENSITIVE_WORDS_CODE then
                self.m_model.m_data.user.desc = ""
                self.m_view:setSignText("")
            end
        end
    end
    local params = {}
    params.desc = desc
    self.m_model:getNetData("user_set_desc", params, signCallback, nil, true)
end

return M;
