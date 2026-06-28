---@class LoginControl : OOControlBase
local M = class("LoginControl", LikeOO.OOControlBase)

--- 页面不可返回
M.m_needBack = false
M.m_notice_pop = false

local __login_bank_key = "Amb_2D"
function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    CS.wt.framework.AudioHelper.Instance:InitCommonBank()
    GameMain.initSound()
    GameVersionConfig.preload_res = false
    self.m_model.m_init_url_count = 0
    --self:initUrl()
    ResourceUtil:LoadRoleSound(__login_bank_key)
    audio:SendEvtUI("Amb_2D_Login")
    ResourceUtil:LoadRoleSound("Bgm")
    audio:SendEvtBGM("Set_State_SignIn")
    self:listenOnBackPressed()
    self:listenPressed()

    self.application_Id = SDKUtil.sdk_params.applicationId
    
    SDKUtil:callSdkFunc(
        "isSandbox",
        {},
        function(rst)
            self.isSandbox = rst.isSandbox
        end
    )

    SDKUtil:callSdkFunc(
        "isNewRealName",
        {},
        function(rst)
            self.isNewRealName = rst.isNewRealName
        end
    )
    
    SDKUtil:callSdkFunc(
        "switchedAccount",
        {},
        function(rst)
            GameMain.reStart()
        end
    )

end

--渠道账号状态监听
function M:listenPressed()
    SDKUtil:RegisterAccountStatusChangedListener(
        function(params)
            if params.type_value == "logoutChannel" then
                SDKUtil:logOut(
                    function()
                        GameMain.reStart()
                    end
                )
            elseif params.type_value == "switchAccount" then
                GameMain.reStart()
            elseif params.type_value == "onExitChannel" then
                SDKUtil:exitGame()
            end
        end
    )
end

--九尾监听
function M:listenNiteActive()
    if SDKUtil.is_gmsdk then
        NineActiveUtil:linstenNineActive()
    end
end

--获取聚合打包上报渠道数据
function M:getMessiData()
    if SDKUtil.is_gmsdk or SDKUtil.is_oneSDK then
        local getServerData = UserDataManager.server_data:getServerData() or {}
        local user_data = UserDataManager.user_data.user_status or {}
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
            serverName = getServerData.server_name or ""
        }
        local json_string = Json.encode(params)
        return json_string
    end
end

function M:listenOnBackPressed()
    SDKUtil:listenOnBackPressed(
        function()
            local json_string = self:getMessiData()
            if static_rootControl then
                SDKUtil:SdkOnExit(
                    function(params)
                        if params.data ~= nil and params.data.code == 0 then
                            local IsHasDialog = params.data.hasDialog
                            if not IsHasDialog then
                                local params = {
                                    on_ok_call = function(msg)
                                        SDKUtil:RoleExitUpload(json_string)
                                        SDKUtil:exitGame()
                                    end,
                                    on_cancel_call = function(msg)
                                    end,
                                    tow_close_btn = true,
                                    text = Language:getTextByKey("new_str_0637")
                                }
                                static_rootControl:openView("Pops.CommonPop", params, "exitGamePop")
                            else
                                SDKUtil:RoleExitUpload(json_string)
                                SDKUtil:exitGame()
                            end
                        end
                    end
                )
            end
        end
    )
end

function M:initUrl()
    if GameVersionConfig.PORTAL_SERVER_ADDRESS_LIST and #GameVersionConfig.PORTAL_SERVER_ADDRESS_LIST > 0 then
        local address_len = #GameVersionConfig.PORTAL_SERVER_ADDRESS_LIST
        local select_index = self.m_model.m_init_url_count % address_len + 1
        GameVersionConfig.PORTAL_SERVER_ADDRESS_URL = GameVersionConfig.PORTAL_SERVER_ADDRESS_LIST[select_index]
    else
        GameVersionConfig.PORTAL_SERVER_ADDRESS_URL =
            self.m_model.m_init_url_count % 2 == 0 and GameVersionConfig.PORTAL_SERVER_ADDRESS_NET or
            GameVersionConfig.PORTAL_SERVER_ADDRESS_CN
    end
    if GameMain.replaceURl ~= nil then
        GameVersionConfig.PORTAL_SERVER_ADDRESS_URL = GameMain.replaceURl
    end
    self.m_model.m_init_url_count = self.m_model.m_init_url_count + 1
    local function responseMethod(response)
        if response then
            local data = Json.decode(response)
            UserDataManager.server_data:setPortalServerAddressData(data)

            UserDataManager:setTimeZone(data.timezone)
            self:updateMsg("open_vedio")
            StatisticsUtil:doPoint("enterGame")
        else
            self:initUrl()
        end
    end
    local url = GameVersionConfig.PORTAL_SERVER_ADDRESS_URL
    NetWork:httpRequest(responseMethod, url, GlobalConfig.GET, {}, "portal_server_address_url", 1, true, 2, true, 1)
end

function M:getNotice()
    if SDKUtil.is_tencent or SDKUtil.is_gmsdk then
        SDKUtil:getNotice(
            function(params)
                UserDataManager:setNotice(params.data)
                self:openView("Notice")
            end,
            6
        )
    else
        self:openView("Notice")
    end
end

function M:noSDkLogin()
    if GameVersionConfig.MASTER_URL == nil then
        local params = {
            on_ok_call = function(msg)
                self:initUrl()
            end,
            no_close_btn = true,
            title = Language:getTextByKey("new_str_0005"),
            text = UserDataManager.server_data.no_server_info
        }
        static_rootControl:openView("Pops.CommonPop", params, "server_url_is_null_pop")
        return
    end
    if self.m_model.m_user_name == nil or self.m_model.m_user_name == "" then
        self:openView("Login.LoginPop")
    else
        if self.m_model.auto_register == true then
            self:autoRegister()
        else
            self:login()
        end
    end
end

function M:updateAccountBtnVisible(isShow)
    local btnObj = self.m_view:findGameObject("account_btn")
    if GameUtil:getpPlatform() == "Editor" then
        btnObj:SetActive(isShow)
    else
        btnObj:SetActive(false)
    end


    if isShow then
        local txt = btnObj.transform:Find("account_text"):GetComponent("Text")
        self.m_view:setObjectVisible("info_node", true)

        SDKUtil:isLogined(
            function(rstPrm)
                --"用户中心" "登录"
                txt.text =
                    rstPrm.result and Language:getTextByKey("sdk_txt_006") or Language:getTextByKey("sdk_txt_007")
                if rstPrm.result then
                    SDKUtil:SDKIsAvailable(
                        function(params) --没有用户中心接口
                            if not params.data then
                                self.m_view:sdkVisible(params.data)
                            end
                        end,
                        "gsdk_api_open_user_center"
                    )
                    if SDKUtil.sdk_params.app == 2 then
                        self.m_view:sdkVisible(true)
                    end
                end
            end
        )
    end
end

function M:sdkInit(params)
    Logger.logAlways(params, "sdkInit params ====")

    if params.result == true then


        SDKUtil.sdk_params.OSPlatform =  params.platform
        SDKUtil.sdk_params.sdkver =  params.sdkver
        SDKUtil.sdk_params.deviceid =  params.deviceid
        SDKUtil.sdk_params.androidid =  params.androidid
        SDKUtil.sdk_params.oaid =  params.oaid
        SDKUtil.sdk_params.fchannel =  params.fchannel
        SDKUtil.sdk_params.subChannel =  params.subChannel
        SDKUtil.sdk_params.ver =  params.versionName or SDKUtil.sdk_params.applicationVersion
        SDKUtil.sdk_params.gaid  = params.androidid or ""
        SDKUtil.sdk_params.idfv = params.idfv or ""
        SDKUtil.sdk_params.user_ip = params.user_ip or ""
        SDKUtil.sdk_params.uid = params.uid or ""
        SDKUtil.sdk_params.imei = params.imei or ""



        StatisticsUtil:doPoint("startSDKLogin")
        self.m_model.m_sdk_login_state = 2 -- 初始化成功
        self.m_model.m_sdk_init_success = true
        self.m_noplatform = params.noplatform
        SDKUtil.is_no_sdk = params.noplatform
        if self.m_noplatform == nil or params.noplatform == true then
            self.m_view:sdkVisible(true)
            self.m_view:startBtnVisible(true)
            self:noSDkLogin()
        else
            self.m_view:sdkVisible(false)
            self.m_view:refreshChannelInfo();
            self:sdkCheckLogin()

            -- setup functions for sdk using
            SDKUtil:setCallback(
                "show_account_btn",
                function(param)
                    self:updateAccountBtnVisible(param.visible)
                end
            )

            SDKUtil:setCallback(
                "user_logout",
                function(param)
                    -- self:setOnceTimer(
                    --     0.2,
                    --     function()
                    --         self:sdkCheckLogin()
                    --     end
                    -- )
                    -- self.m_view:tencentLoginBtnVisible(true)
                    -- self.m_view:LoginedBtnsVisible(false)
                    self.m_view:startBtnVisible(false)
                    self:updateAccountBtnVisible(true)
                end
            )

            local login_callback_func ="on_login_callback" 
            SDKUtil:setCallback(
                login_callback_func,
                function(param)
                    UserDataManager.client_data:setSdkToken(param.token)
                end
            )

            SDKUtil:callSdkFunc(
                "set_login_callback",
                {
                    on_login_event = login_callback_func
                },
                function(rst)
                    UserDataManager.client_data.update_login_token = true
                end
            )
        end

        SDKUtil:sendBitrack(SDKUtil.BI_SdkInited)

    else
        self.m_model.m_sdk_login_state = -2 -- 初始化失败
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0450"), delay_close = 2})
        SDKUtil:sdkInit(handler(self, self.sdkInit))
    end
end

--软件更新
function M:CheckForceUpgrade()
    if SDKUtil.is_gmsdk then
        SDKUtil:CheckForceUpgrade(
            function(data)
                self.IsForceUpdate = data.data.IsForceUpdate
                --local params =
                --{
                --    isreward = true,
                --    on_ok_call = function(msg)
                --        SDKUtil:StartCustomUpgrade()
                --    end,
                --    on_cancel_call = function(msg)
                --        SDKUtil:onCancelBtnClick()
                --    end,
                --    reward_text = Language:getTextByKey(data.data.text),
                --}
                --self:openView("Pops.CommonPop",params,nil,true)
            end
        ) --字节检测软件更新
    end
end

--设置服务器数据
function M:setServer(callback)
    if SDKUtil.is_gmsdk then --设置服务器数据
        SDKUtil:getFetchZonesAndRolesList(
            function(params)
                if params.Zones == nil or #params.Zones == 0 then --提示重登
                    GameUtil:lookInfoTips(static_rootControl, {msg = "new_str_0935", delay_close = 2})
                    return
                end
                UserDataManager.server_data:setAllServerData(params.Zones)
                UserDataManager.server_data:setAllRoleData(params.Roles)
                if params.Roles ~= nil then
                    table.sort(
                        params.Roles,
                        function(data1, data2)
                            return data1.login_time > data2.login_time
                        end
                    )
                    local last_server_info = {}
                    for i, v in ipairs(params.Zones) do
                        if params.Roles[1] ~= nil and v.server == params.Roles[1].server_id then
                            table.insert(last_server_info, {zone = v, role = params.Roles[1]})
                        elseif params.Roles[2] ~= nil and v.server == params.Roles[2].server_id then
                            table.insert(last_server_info, {zone = v, role = params.Roles[2]})
                        end
                    end
                    table.sort(
                        last_server_info,
                        function(data1, data2)
                            return data1.role.login_time > data2.role.login_time
                        end
                    )
                    UserDataManager.server_data:setLastServer(last_server_info)
                end
                callback()
            end,
            GameVersionConfig.BYTE_DANCE_SERVER_VERSION
        )
    end
end

function M:sdkCheckLogin()
    SDKUtil:isLogined(
        function(params)
            Logger.log(params, "sdkCheckLogin isLogined ====")
            if params.result == true and self.m_model.m_sdk_login == true then
                self.m_view:startBtnVisible(true)
                self:platformAccess()
                self.m_view:refreshClientService()
            else
                if self.m_model.m_sdk_init_success then
                    if self.m_model.m_sdk_login_state == 3 then
                        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0447"), delay_close = 2})
                    else
                        self.m_model.m_sdk_login_state = 3 -- sdk登陆
                        if SDKUtil.is_tencent then
                            SDKUtil:autoLogin(handler(self, self.autoLoginCall))
                        else
                            SDKUtil:logIn(handler(self, self.sdkLoginCall), Json.encode({inGameLogin = false}))
                        end
                    end
                else
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0449"), delay_close = 2})
                end
            end
        end
    )
end

-- 腾讯sdk自动登录回调逻辑
function M:autoLoginCall(params)
    if params.result == true then
        self.m_view:startBtnVisible(true)
        self.m_model.m_sdk_login_state = 4 -- sdk登陆成功
        --U3DUtil:PlayerPrefs_SetInt("auto_login", 0)
        self.m_model:setSdkAccount(params)
        self:platformAccess()
        self.m_view:refreshClientService()
    else
        self.m_model.m_sdk_login_state = -4 -- sdk登陆成功
        --GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0448"), delay_close = 2})
        self:getNotice()
        self.m_view:tencentLoginBtnVisible(true)
    end
end

function M:__checkRealName(callback)
    self.getRealNameSeccuss =
        SDKUtil:callSdkFunc(
        "fetchRealNameInfo",
        {},
        function(fetchRealNameRst)
            self.isRealNamed = fetchRealNameRst.IsVerified
            if callback then
                callback(true)
            end
        end
    )

    if not self.getRealNameSeccuss then
        if callback then
            callback(false)
        end
    end
end

--[[
verify_status
说明
1 新用户拉起本人实名页面
2 新用户拉起监护人实名页面
3 新用户拉起监护人认证页面
4 旧用户拉起监护人实名页面
5 旧用户拉起监护人认证页面
]]
function M:__verify_status(id, callback)
    local url = "https://bsdk"
    if self.isSandbox then
        url = url .. "-sandbox"
    end
    url = url .. ".snssdk.com/h5/personal_protection/verify?verify_status=" .. id .. "&theme=purple"
    Logger.log(url, "webView")
    SDKUtil:openUrl(
        url,
        function(verifyStatusRst)

            if callback then
                callback(verifyStatusRst)
            end
        end
    )
end

-- 登录sdk回调逻辑
function M:sdkLoginCall(params)
    local function __onLoginSuccess()
        self.m_view:startBtnVisible(true)
        if params.result == true then
            self.m_model.m_sdk_login_state = 4 -- sdk登陆成功
            --U3DUtil:PlayerPrefs_SetInt("auto_login", 1)
            self.m_model:setSdkAccount(params)
            self:platformAccess()
        else
            self.m_model.m_sdk_login_state = -4 -- sdk登陆成功
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0448"), delay_close = 2})
        end
        self.m_view:refreshClientService()
        StatisticsUtil:doPoint("sdkLoginSuccess")
    end

    -- 拉起本人实名页面
    local function __authRealNameWeb()
        Logger.log("gsdk 要求实名验证, 拉起实名验证页面", "sdk login-------->")
        self:__verify_status(
            1,
            function()
                self:__checkRealName(
                    function(rst)
                        if self.isRealNamed then
                            --new verify user ,re login
                            SDKUtil:logIn(
                                function(newloginParam)
                                    self.m_view:startBtnVisible(true)
    
                                    if newloginParam.result == true then
                                        self.m_model.m_sdk_login_state = 4 -- sdk登陆成功
                                        --U3DUtil:PlayerPrefs_SetInt("auto_login", 1)
                                        self.m_model:setSdkAccount(newloginParam)
                                        self:platformAccess()
                                    else
                                        self.m_model.m_sdk_login_state = -4 -- sdk登陆成功
                                        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0448"), delay_close = 2})
                                    end
                                    StatisticsUtil:doPoint("sdkLoginSuccess")
                                end
                            , Json.encode({inGameLogin = true}))
                        else
                            -- login_out or auth
                            local showPopParam = {
                                on_ok_call = function(msg)
                                    __authRealNameWeb()
                                end,
                                on_cancel_call = function(msg)
                                    SDKUtil:logOut(
                                        function()
                                            self:setOnceTimer(
                                                0.3,
                                                function()
                                                    Logger.log("gsdk 要求实名验证, 放弃实名验证, logout ", "sdk login-------->")
                                                    GameMain.reStart()
                                                end
                                            )
                                        end
                                    )
                                end,
                                no_close_btn = true,
                                -- title = Language:getTextByKey("login_str_0001"),
                                title = Language:getTextByKey("sdk_txt_notify"),
                                text = Language:getTextByKey("sdk_txt_notify_txt"),
                                tow_close_btn = true,
                                no_close_btn = false,
                                ok_text = Language:getTextByKey("sdk_txt_realName"),
                                cancel_text = Language:getTextByKey("sdk_txt_logout")
                            }
                            static_rootControl:openView("Pops.CommonPop", showPopParam)
                        end
                    end
                )
            end
        )
    end

    if self.isNewRealName then
        local function _newRealName()
            SDKUtil:callSdkFunc(
            "checkRealName",
            {},
            function(rst)
                if rst.passed then
                    -- if false then
                    Logger.log("rst.passed ", "sdk login--------------------------------------->")
                    __onLoginSuccess()
                else
                    local showPopParam = {
                        on_ok_call = function(msg)
                            _newRealName()
                        end,
                        on_cancel_call = function(msg)
                            SDKUtil:logOut(
                                function()
                                    self:setOnceTimer(
                                        0.3,
                                        function()
                                            Logger.log("gsdk 要求实名验证, 放弃实名验证, logout ", "sdk login-------->")
                                            GameMain.reStart()
                                        end
                                    )
                                end
                            )
                        end,
                        no_close_btn = true,
                        -- title = Language:getTextByKey("login_str_0001"),
                        title = Language:getTextByKey("sdk_txt_notify"),
                        text = Language:getTextByKey("sdk_txt_notify_txt"),
                        tow_close_btn = true,
                        no_close_btn = false,
                        ok_text = Language:getTextByKey("sdk_txt_realName"),
                        cancel_text = Language:getTextByKey("sdk_txt_logout")
                    }
                    static_rootControl:openView("Pops.CommonPop", showPopParam)

                end
            end
        )
        end
        _newRealName()
    else

        -- 通过 fetchRealNameInfo 接口 验证
        -- login by realname
        self:__checkRealName(
            function(callfunc_suc)
                if callfunc_suc then
                    if self.isRealNamed then
                        __onLoginSuccess()
                    else
                        -- self.isNewUser = true
                        __authRealNameWeb()
                    end
                else
                    --老版本的客户端，没有fetchRealNameInfo接口
                    --不进行家长验证
                    __onLoginSuccess()
                end
            end
        )
    end

end

function M:platformAccess_onResponse(response)
    if response then
        Logger.logAlways(response, "platformAccess_onResponse rsp ==")
        self:processAccessData(response)
    else
        SDKUtil:logOut(
            function()
                self:setOnceTimer(
                    0.1,
                    function()
                        GameMain.reStart()
                    end
                )
            end
        )
    end
end

function M:platformAccess_req()

    local params = {}
    params.channel = self.m_model.m_channel
    params.sdkChannel = self.m_model.m_sdkChannel
    params.session_id = self.m_model.m_session
    params.openid = self.m_model.m_uid
    params.uid = self.m_model.m_uid
    params.os = self.m_model.m_msdk_os
    params.cfg_channel = self.m_model.m_config_channel
    params.sdk_channel_mark1 = self.m_model.subSdkChannel




    -- gsdk params
    params.platform = self.m_model.m_platform
    params.token = self.m_model.m_token
    params.userid = self.m_model.m_userid
    SDKUtil:appendPlatformParam(params)
    if self.m_model.m_reg_channel then
        params.reg_channel = self.m_model.m_reg_channel
    end
    if self.m_model.m_platform then
        params.platform = self.m_model.m_platform
    end

    Logger.logAlways(params, "platformAccess params ==")

    self.m_model:getNetData(
        "platform_access",
        params,
        function(rsp)
            Logger.logAlways(rsp, "platformAccess rsp ==")
            self:platformAccess_onResponse(rsp)

        end,
        nil,
        true
    ) -- a
end

function M:platformAccess()
    if GameVersionConfig.MASTER_URL == nil then
        local params = {
            on_ok_call = function(msg)
                self:initUrl()
            end,
            no_close_btn = true,
            title = Language:getTextByKey("new_str_0005"),
            text = UserDataManager.server_data.no_server_info
        }
        static_rootControl:openView("Pops.CommonPop", params, "server_url_is_null_pop")
        return
    end
    if self.m_model.m_uid then
        SDKUtil:pushRegister(self.m_model.m_uid)
    end

    self:CheckForceUpgrade()

    self:platformAccess_req()
end

function M:processAccessData(response)
    UserDataManager.client_data.user_account = response.account
    UserDataManager.client_data.openid = response.openid
    UserDataManager.client_data.sk = response.sk
    UserDataManager.client_data:setSk(response.sk)
    UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
    UserDataManager.server_data:setServerData(response.current_server)
    UserDataManager.server_data:setUserSid(response.sid)
    GameMain.replaceURl = response.env_switch
    local current_server = response.current_server or {}
    local uid = current_server.uid or ""
    UserDataManager.client_data.is_new_user = uid == ""

    if SDKUtil.is_gmsdk then
        local server, role = UserDataManager.server_data:getFirstServer()
        if server then
            UserDataManager.server_data:setServerData(server)
            UserDataManager.client_data.is_new_user = role.uid == ""
        else
            -- 未取到游戏服
            local params = {
                on_ok_call = function(msg)
                    self:initUrl()
                end,
                no_close_btn = true,
                title = Language:getTextByKey("new_str_0005"),
                text = Language:getTextByKey("new_str_1061")
            }
            static_rootControl:openView("Pops.CommonPop", params, "server_is_null_pop")
            return
        end
    end
    -- 未取到游戏服地址
    if GameVersionConfig.SERVICE_URL == nil then
        local params = {
            on_ok_call = function(msg)
                self:initUrl()
            end,
            no_close_btn = true,
            title = Language:getTextByKey("new_str_0005"),
            text = UserDataManager.server_data.no_server_info
        }
        static_rootControl:openView("Pops.CommonPop", params, "server_url_is_null_pop")
        return
    end

    SDKUtil:sendBitrack(SDKUtil.BI_ServerLogined)

    local real_name_data = UserDataManager.local_data:getLocalDataByKey("realName", {})
    if SDKUtil.is_tencent and self.m_model.m_uid and not real_name_data[self.m_model.m_uid] then
        real_name_data[self.m_model.m_uid] = true
        UserDataManager.local_data:setLocalDataByKey("realName", real_name_data)
        local params = {
            on_ok_call = function(msg)
                self:openView("Login.Update")
            end,
            no_close_btn = true,
            title = Language:getTextByKey("login_str_0001"),
            text = Language:getTextByKey("login_str_0002")
        }
        static_rootControl:openView("Pops.CommonPop", params)
        StatisticsUtil:doPoint("realNameTips")
    elseif self.IsForceUpdate then
        --等待更新
    else
        self:openView("Login.Update")
    end

    self.m_view:refreshUI(true)
    self.m_view:tencentLoginBtnVisible(false)
    self.m_view:LoginedBtnsVisible(true)
    StatisticsUtil:doPoint("gameLoginSuccess")
    self:listenNiteActive()
    -- local updateParam = {
    --     server_id = UserDataManager.server_data:getServerId()
    -- }
    -- SDKUtil:handleGameEvent("get_sdk_products", updateParam)



end

function M:logOut()
    if SDKUtil.is_tencent then
        self.m_view:tencentLoginBtnVisible(true)
    end
    self.m_view:LoginedBtnsVisible(false)
    self.m_view:startBtnVisible(false)
    self:updateAccountBtnVisible(true)
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:closeView()
    elseif msg == "start_btn" then
        local application_Id = SDKUtil.sdk_params.applicationId
        if self.m_model.tencent_agreement == 0 and SDKUtil.is_gmsdk and application_Id ~= "com.hermes.wl" and SDKUtil.sdk_params.app == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1049"), delay_close = 2})
            return
        end
        self.m_view:playStartBtnEffect()
        local current_sever_data = UserDataManager.server_data:getServerData()
        if current_sever_data == nil then
            self:initUrl()
            return
        end
        if current_sever_data.is_open ~= 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0941"), delay_close = 2})
            return
        end
        --[[
        if current_sever_data.is_open == "InMaintenance" then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0941"), delay_close = 2})
            return
        elseif current_sever_data.is_open == "Offline" then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0942"), delay_close = 2})
            return
        elseif current_sever_data.is_open == "None" then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0943"), delay_close = 2})
            return
        end
        ]]--
        if SDKUtil.is_tencent and self.m_model.tencent_agreement == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0518"), delay_close = 2})
            return
        end
        if GameVersionConfig.MASTER_URL == nil then
            GameUtil:lookInfoTips(self, {msg = "new_str_0848", delay_close = 2})
            self:initUrl()
            return
        end
        self:setOnceTimer(
                0.2,
                function()
                    self:startGame()
                end
        )
    elseif msg == "select_server_btn" then
        local serverData = UserDataManager.server_data:getAllServerData()
        if SDKUtil.is_gmsdk then
            if GameVersionConfig.MASTER_URL == nil or #serverData <= 0 then
                GameUtil:lookInfoTips(self, {msg = "new_str_0849", delay_close = 2})
                self:initUrl()
                return
            end
        end
        self:getServerList()
    elseif msg == "account_btn" then
        if SDKUtil.is_oneSDK and SDKUtil.sdkChannel == "yyh" then
            SDKUtil:logOut(
                    function()
                        GameMain.reStart()
                    end
            )
            return
        end
        if GameVersionConfig.MASTER_URL == nil then
            GameUtil:lookInfoTips(self, {msg = "new_str_0850", delay_close = 2})
            self:initUrl()
            return
        end

        SDKUtil.callbackMap["realname_end"] = function(param)
            if param.success then
                self.m_view:enableStartBtn(false)

                SDKUtil:antiAddiction(
                    0,
                    function(rst)
                        -- self:setOnceTimer(
                        --     0.25,
                        --     function()
                        self.m_view:enableStartBtn(true)
                        --     end
                        -- )

                        if not rst then
                            SDKUtil:logOut(
                                function()
                                    GameMain.reStart()
                                end
                            )
                        end
                    end
                )
            end
        end

        if not SDKUtil:handleGameEvent("account_btn") then
            self:openView("Login.LoginPop")
        end
    elseif msg == "select_server" then
        self.m_view:refreshUI()
    elseif msg == "initUrl" then
        self:initUrl()
    elseif msg == "open_vedio" then
        --end
        --if U3DUtil:PlayerPrefs_GetInt("player_vedio", 0) == 0 then
        --self:openView("Pops.VedioPlayerPop", {callback = function()
        --	self:vedioEndCall()
        --end})
        --U3DUtil:PlayerPrefs_SetInt("player_vedio", 1)
        --StatisticsUtil:doPoint("startMovie")
        --else
        self:vedioEndCall()
    elseif msg == "vedio_btn" then
        self:openView("Pops.VedioPlayerPop")
    elseif msg == "notice_btn" then
        self:getNotice()
    elseif msg == "close_sync_load_big_loading" then
        self:closeView("Loading.SyncLoadBigLoading")

        self:goMainScene()
    elseif msg == "open_notice" then
        --else
        --	self.m_notice_pop = true
        --end
        --if self.m_notice_pop then
        self:getNotice()
    elseif msg == "sdk_login_btn" then
        if SDKUtil.is_gmsdk then --是字节sdk
            SDKUtil:isLogined(
                function(rstPrm)
                    if rstPrm.result == false then
                        SDKUtil:logIn(handler(self, self.sdkLoginCall))
                    else
                        self:initUrl()
                    end
                end
            )
        elseif self.m_model.m_sdk_login ~= true then
            SDKUtil:logIn(handler(self, self.sdkLoginCall))
        end
    elseif msg == "url_list_btn" then
        self:openView("Login.UrlPop")
    elseif msg == "crash_btn" then
        CS.LuaGameLaunch.testCrashes()
    elseif msg == "wechat_btn" then
        SDKUtil:logIn(handler(self, self.sdkLoginCall), "WeChat")
    elseif msg == "qq_btn" then
        SDKUtil:logIn(handler(self, self.sdkLoginCall), "QQ")
    elseif msg == "logOut_btn" then
        SDKUtil:logOut(handler(self, self.logOut))
    elseif msg == "agreement_btn" then
        if self.m_model.tencent_agreement == 0 then
            self.m_model.tencent_agreement = 1
        else
            self.m_model.tencent_agreement = 0
        end
        U3DUtil:PlayerPrefs_SetInt("tencent_agreement", self.m_model.tencent_agreement)
        UserDataManager.local_data:setLocalDataByKey("gsdk_agreement",self.m_model.tencent_agreement)
        self.m_view:freshAgreement()
    elseif msg == "contract_text_btn" then  --隐私协议
        if SDKUtil.is_gmsdk then
            if self.application_Id == "com.hermes.wl.jh" then
                SDKUtil:openUrl("https://www.seayoo.com/pages/xianxia-privacy.html")
            else
                SDKUtil:openUrl("https://sf1-cdn-tos.douyinstatic.com/obj/ies-hotsoon-draft/GSDK/privacy.html") 
            end
        elseif SDKUtil.is_tencent then
            SDKUtil:openUrl("http://game.qq.com/contract.shtml")
        end
    elseif msg == "privacy_text_btn" then  --网络协议
        if SDKUtil.is_tencent then
            SDKUtil:openUrl("https://game.qq.com/privacy_guide.shtml")
        elseif SDKUtil.is_gmsdk then
            if self.application_Id == "com.hermes.wl.jh" then
                SDKUtil:openUrl("https://www.seayoo.com/pages/xianxia-user-agreement.html")
            else
                SDKUtil:openUrl("https://sf3-cdn-tos.douyinstatic.com/obj/ies-hotsoon-draft/GSDK/user_contract_newdomain.html")
            end
            
        end
    elseif msg == "age_Img" then --年齡
        local params = {
            content = Language:getTextByKey("new_str_0909"),
            title = Language:getTextByKey("new_str_0908")
        }
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "customer_btn" then --客服

        --local url =
        --    string.format(
        --    "https://cs.dailygn.com?role_id=%s&server_id=%s",
        --    UserDataManager.user_data:getUid(),
        --    UserDataManager.server_data:getServerId()
        --) --正式环境
        --SDKUtil:openUrl(url)
        local params =
        {
            no_close_btn = true,
            text = "",
        }

        if SDKUtil.sdk_params.isCS == "1" then
            params.text = Language:getTextByKey("service_duoku_content")
            self:openView("Pops.CommonPop", params)
        elseif  SDKUtil.sdk_params.isCS == "2" then
            params.text = Language:getTextByKey("service_bStation_content")
            self:openView("Pops.CommonPop", params)
        elseif SDKUtil.sdk_params.isCS == "3" then
            CS.UnityEngine.Application.OpenURL("https://adl.netease.com/d/g/mmwb/c/sdkhelp")
            --SDKUtil:openUrl("https://adl.netease.com/d/g/mmwb/c/sdkhelp")
        elseif  SDKUtil.sdk_params.isCS == "4" then
            params.text = Language:getTextByKey("service_lei_dian_content")
            self:openView("Pops.CommonPop", params)
        end

    elseif msg == "repair_btn" then --修复
        local params = {
            on_ok_call = function(msg)
                local LuaFileHelper = CS.wt.framework.LuaFileHelper.Inst
                LuaFileHelper:DeleteDir("Bundles", true)
                LuaFileHelper:DeleteDir("LuaScripts", true)
                LuaFileHelper:DeleteDir("mp4", true)
                LuaFileHelper:DeleteDir("Audio", true)
                LuaFileHelper:DeleteDir("tempZip", true)
                GameVersionConfig = LuaReload("Start.GameVersionConfig")
                U3DUtil:PlayerPrefs_SetString(
                    "game_resources_verion",
                    tostring(GameVersionConfig.GAME_RESOURCES_VERION)
                )
                U3DUtil:PlayerPrefs_SetString("client_verion", tostring(GameVersionConfig.CLIENT_VERSION))
                U3DUtil:PlayerPrefs_Save()
                GameMain.download_game_resources = true
                GameMain.reStart()
            end,
            on_no_call = function(msg)
                if GameVersionConfig.readyChangeTick == nil then
                    GameVersionConfig.readyChangeTick = 0
                end
                GameVersionConfig.readyChangeTick = GameVersionConfig.readyChangeTick + 1
                if GameVersionConfig.readyChangeTick > 10 then
                    GameVersionConfig.readyChangeTick = 0
                    GameMain.replaceURl = GameMain.replaceURl ~= nil and GameMain.replaceURl or "https://dl-jxjh.duoku.com/jxdk/entrance/dk_test.json"
                    GameMain.reStart()
                end
            end,
            isreward = true,
            no_close_btn = true,
            text = Language:getTextByKey("tid#fixtipstext_01")
        }
        static_rootControl:openView("Pops.CommonPop", params, "UncompressCodeErrorPop")
    elseif msg == "refresh_serverInfo" then
        self.m_view:refreshUI()
    end
end

function M:vedioEndCall()
    --self.m_view:releaseVisibleView()

    local _isPrivacyQuit = false
    SDKUtil:callSdkFunc(
        "isPrivacyQuit",
        {},
        function( rst)
            _isPrivacyQuit = rst.isPrivacyQuit
        end)

    if not _isPrivacyQuit then
        self.m_model.m_sdk_login_state = 1 -- 初始化

        if not SDKUtil:callSdkFunc(
            "isAgreePrivacy",
            {},
            function(rst)
                if rst.isAgreePrivacy then
                    UserDataManager.client_data.device_mark = U3DUtil:Get_SystemInfo_Indentifier() 
                end
            end
        ) then
            
            UserDataManager.client_data.device_mark = U3DUtil:Get_SystemInfo_Indentifier() 
        end

        SDKUtil:sdkInit(handler(self, self.sdkInit))
    end


    
    --local function eventBack()
    --	self:updateMsg("open_notice")
    --end
    --self:setOnceTimer(2, eventBack)
end

function M:autoRegister()
    local account = self.m_model.m_user_name
    local password = self.m_model.m_user_password

    local params = {passwd = tostring(password), account = tostring(account)}
    SDKUtil:appendPlatformParam(params)
    local netCallback = function(response)
        U3DUtil:PlayerPrefs_SetString("username", account)
        U3DUtil:PlayerPrefs_SetString("password", password)

        UserDataManager.client_data.user_account = tostring(account)
        Logger.log(account, "account =========")
        --注册完之后直接进游戏
        UserDataManager.client_data:setSk(response.sk)
        UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
        UserDataManager.server_data:setServerData(response.current_server)
        UserDataManager.server_data:setUserSid(response.sid)
        UserDataManager.client_data.is_new_user = true

        self:openView("Login.Update")
        self.m_view:refreshUI(true)
        StatisticsUtil:doPoint("gameLoginSuccess")
    end
    self.m_model:getNetData("register", params, netCallback) -- a
end

-- 有本地账号默认自动登录
function M:login()
    local account = self.m_model.m_user_name
    local password = self.m_model.m_user_password
    if account ~= "" and password ~= "" then
        local params = {passwd = tostring(password), account = tostring(account)}
        SDKUtil:appendPlatformParam(params)
        local function netCallback(response, tag)
            if response then
                U3DUtil:PlayerPrefs_SetString("username", account)
                U3DUtil:PlayerPrefs_SetString("password", password)
                UserDataManager.client_data.user_account = tostring(account)
                UserDataManager.client_data:setSk(response.sk)
                UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
                UserDataManager.server_data:setServerData(response.current_server)
                UserDataManager.server_data:setUserSid(response.sid)
                local current_server = response.current_server or {}
                local uid = current_server.uid or ""
                UserDataManager.client_data.is_new_user = uid == ""
                if GameVersionConfig.BYTE_DANCE_ACCOUNT_TEST then
                    local accountTest = CustomRequire("UI.Login.AccountTest")
                    accountTest:init()
                end
                self:openView("Login.Update")
                self.m_view:refreshUI(true)
                StatisticsUtil:doPoint("gameLoginSuccess")
            else
            end
        end
        self.m_model:getNetData("login", params, netCallback, nil, true) -- a
    end
end

-- 开始游戏
function M:startGame()



    local account = UserDataManager.client_data.user_account
    local server = UserDataManager.server_data:getServerId()

    if account and server then
        local params = {account = tostring(account), server = tostring(server)}

        params.channel = self.m_model.m_channel
        params.session_id = self.m_model.m_session
        params.openid = self.m_model.m_uid
        params.uid = self.m_model.m_uid
        params.os = self.m_model.m_msdk_os
        params.cfg_channel = self.m_model.m_config_channel
        -- gsdk params
        params.platform = self.m_model.m_platform
        params.token = self.m_model.m_token
        params.userid = self.m_model.m_userid
        SDKUtil:appendPlatformParam(params)
        if self.m_model.m_reg_channel then
            params.reg_channel = self.m_model.m_reg_channel
        end
        if self.m_model.m_platform then
            params.platform = self.m_model.m_platform
        end

        if SDKUtil.is_tencent then
            CS.WTTssSDK.GetSdkCoreData(
                function(coreData)
                    params.sec_report_data = coreData
                end
            )
        end

        WhalSDKUtil:OnAccountLogin(account)

        -- self.m_view:enableStartBtn(false)

        -- SDKUtil:antiAddiction(
        --     2,
        --     function(passTest)
        -- self:setOnceTimer(
        --     0.2,
        --     function()
        self.m_view:enableStartBtn(true)
        --     end
        -- )

        -- if not passTest then
        --     SDKUtil:logOut(handler(self, self.logOut))
        -- else
        local function netCallback(response)
            if response then

                SDKUtil:onEventRegister()
                SDKUtil:sendBitrack(SDKUtil.BI_LoadingGame)

                UserDataManager.user_data.uid = response.uid
                local server_data = table.copy(UserDataManager.server_data:getServerData())
                table.merge(UserDataManager.server_data:getServerData(), response.current_server)
                local user_server = UserDataManager.server_data:getServerData()
                user_server.server_name = server_data.server_name
                user_server.server = server_data.server
                if server_data.domain ~= "" then
                    user_server.domain = server_data.domain
                end
                UserDataManager.server_data:setServerData(user_server)
                NetWork:resetServerRequestCount()
                NetWork:hopeHandle(
                    response,
                    function()
                        self.m_view:setObjectVisible("info_node", false)
                        self.m_view:setObjectVisible("Loading_Sence_Text", true)
                        self:userGameInfo()
                    end
                )

                local updateParam = {
                    server_id = UserDataManager.server_data:getServerId(),
                    role_id = response.uid
                }
                SDKUtil:handleGameEvent("get_sdk_products", updateParam)
            end
        end

        StatisticsUtil:doPoint("clickEnterGameButton")
        self.m_model:getNetData("login_server", params, netCallback, nil, true) -- a
    else
        -- Logger.log(self.m_noplatform,"m_noplatform ====")
        if self.m_noplatform == nil or self.m_noplatform == true then

            self:openView("Login.LoginPop")
            StatisticsUtil:doPoint("clickEnterGameButton")
        else
            self:sdkCheckLogin()
        end
    end
end

-- 请求玩家本地存储数据
function M:userGameInfo()
    local function netCallback(response)
        if response then
            UserDataManager:updateUserGameInfo(response)
            ChatUtil:connectChatServer()
            PrestigeUtil:init()
            self:userMain()
        else
            self.m_view:setObjectVisible("info_node", true)
        end
    end
    self.m_model:getNetData("user_game_info", nil, netCallback, nil, true)
end

-- 请求主场景数据
function M:userMain()
    --self:goMainScene()
    if SceneManager ~= nil then
        SceneManager:init(0)
    end
    SceneManager:changeScene(SceneManager.SceneID.HangUpScene, nil, false, false)
    self.m_view:setObjectVisible("Loading_Sence_Text", false)
end

-- 测试获取服务器列表，正常流程不会用到
function M:getServerList()
    local account = UserDataManager.client_data.user_account
    if SDKUtil.is_gmsdk then
        --SDKUtil:getFetchZonesAndRolesList(
        --    function(params)
        --        self:openView("Login.LoginServer", {zones = params.Zones, roles = params.Roles})
        --    end
        --)
        self:openView("Login.LoginServer")
        StatisticsUtil:doPoint("startSelectServer")
    else
        if account then
            local params = {account = tostring(account)}
            local netCallback = function(response)
                UserDataManager.server_data:setAllServerData(response.servers)
                self:openView("Login.LoginServer", response.servers)
            end
            self.m_model:getNetData("server_list", params, netCallback)
        end
    end
end

-- 进入主场景
function M:goMainScene()
    --CS.LoginCamera.Inst:ChangeAnim("Camera_Run");

    SDKUtil:sendBitrack(SDKUtil.BI_EnterGame)

    self:setOnceTimer(
        0.1,
        function()
            local vedio_play = UserDataManager.local_data:getUserDataByKey("player_vedio", 0)
            if GameVersionConfig.Is_BIGGAMEAPP then
                vedio_play = 1
            end
            vedio_play = 1 --屏蔽cg
            local stageid = UserDataManager:getCurStage()
            if stageid == 0 and vedio_play == 0 then
                audio:SendEvtUI("Stop_SignIn")
                self:openView(
                    "Pops.VedioPlayerPop",
                    {
                        callback = function()
                            --self:openView("Demonstrate")
                            self:openView("Main")
                            WhalSDKUtil:OnRoleLogin(UserDataManager.user_data, UserDataManager.server_data)
                        end,
                        close_btn_delay = 5,
                        close_view_flag = true,
                        close_btn_type = 1
                    }
                )
                UserDataManager.local_data:setUserDataByKey("player_vedio", 1)
                StatisticsUtil:doPoint("startMovie")
            else
                self:openView("Main")
                WhalSDKUtil:OnRoleLogin(UserDataManager.user_data, UserDataManager.server_data)
            end
        end
    )
end

function M:openViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Login.Update" then
        self.m_view:setObjectVisible("info_node", false)
    end
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Login.Update" then
        self:updateAccountBtnVisible(true)
        if GameMain.download_game_resources ~= true then
            self.m_view:enableStartBtn(false)

            -- SDKUtil:antiAddiction(
            --     2,
            --     function(rst)
            self.m_view:enableStartBtn(true)

            --         if rst then
            self.m_view:setObjectVisible("info_node", true)
            local auto_login = U3DUtil:PlayerPrefs_GetInt("auto_login", 0)
            Logger.log(auto_login, "auto_login ===")
            if auto_login == 1 then
                U3DUtil:PlayerPrefs_SetInt("auto_login", 0)
                U3DUtil:PlayerPrefs_Save()
                if SDKUtil.is_tencent and self.m_model.tencent_agreement == 0 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0518"), delay_close = 2})
                    return
                end
                self:startGame()
            else
                local notice_first = U3DUtil:PlayerPrefs_GetInt("notice_first", 1)
                if notice_first == 1 then
                    self:getNotice()
                else
                    U3DUtil:PlayerPrefs_SetInt("notice_first", 1)
                    U3DUtil:PlayerPrefs_Save()
                end
            end
        --     else
        --         SDKUtil:logOut(handler(self, self.logOut))
        --     end
        -- end
        -- )
        end
    elseif view_name == "Notice" then
        SDKUtil:handleGameEvent("notice_end")
    end
end

-- 若老玩家回归选择了新服，则把这个新服作为默认服
function M:checkPlayerBackChoseServer()
    local player_back_server_chose_flag = UserDataManager.local_data:getLocalDataByKey("player_back_server_chose_flag", false)
    if player_back_server_chose_flag == true then
        local server_data_cache =  UserDataManager.local_data:getLocalDataByKey("player_back_server_chose_server_data")
        if server_data_cache then
            UserDataManager.server_data:setServerData(server_data_cache)
            self.m_view:refreshUI()
        end
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    SDKUtil:setCallback("show_account_btn", nil)
    SDKUtil:setCallback("user_logout", nil)
    M.super.destroy(self)
end

return M
