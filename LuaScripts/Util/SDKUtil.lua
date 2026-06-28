------------------- SDKUtil

local M = {}

M.callbackMap = {}
M.is_no_sdk = true
M.sdk_params = {
    app = 1, -- Android = 1，ios = 2
    platform = "editor",
    device = "",
    sysversion = "",
    notch = false,
    notchheight = 0,
    is_tencent = false,
    isCS = "0"
}

M.chargeProductsMap = nil
M.is_oneSDK = true
M.sdkVersion = "1.2.5.0"


--点击游戏（SDK初始化完成）     SdkInited
--SDK登录/注册成功   SdkLogined
--游戏服务器登录成功  ServerLogined
--更新逻辑开始      UpdateBegin
--更新逻辑完成      UpdateEnd
--公告显示          NoticeShow
--加载游戏          LoadingGame
--进入游戏          EnterGame

M.BI_SdkInited = "SdkInited"
M.BI_SdkLogined = "SdkLogined"
M.BI_ServerLogined = "ServerLogined"
M.BI_UpdateBegin = "UpdateBegin"
M.BI_UpdateEnd = "UpdateEnd"
M.BI_NoticeShow = "NoticeShow"
M.BI_LoadingGame = "LoadingGame"
M.BI_EnterGame = "EnterGame"




local __SystemInfo = CS.UnityEngine.SystemInfo
local __Application = CS.UnityEngine.Application
local __SRFileUtil = CS.SRFileUtil
local __HttpRequest = CS.wt.framework.HttpRequest.Inst


function M:init()
    local GameCenter = U3DUtil:GameObject_Find("GameCenter")
    local sdk_component = GameCenter:GetComponent("SdkComponent")

    if sdk_component.setLB4gCallback then
        sdk_component:setLB4gCallback(function()

            static_rootControl:setTimer(150,
                    function()

                        local params = {
                            on_ok_call = function(msg)
                            end,
                            on_cancel_call = function(msg)
                            end,
                            no_close_btn = true,
                            ok_text = Language:getTextByKey("lb_down_ok_btn"),
                            text = Language:getTextByKey("lb_down_info")
                        }

                        static_rootControl:openView("Pops.CommonPop", params)

                    end)
        end)
    end
    

    self.m_sdk_helper = sdk_component.sdk_helper
    self.is_tencent = sdk_component.isTencent
    self.is_gmsdk = sdk_component.GSdkIsActive
    if U3DUtil:Is_Platform("IPhonePlayer") then
        self.sdk_params.app = 2
    end
    local function callbackAction(params)
        if params then
            local t_p = Json.decode(params)
            --Logger.log("callbackAction " .. t_p.func, params)
            if t_p.func and self.callbackMap[t_p.func] then
                self.callbackMap[t_p.func](t_p)
            end
        end
    end

    self.callbackMap["logOut"] = function(params)
        --Logger.log("logout from callback", "sdk logout from callback-------->")
        GameMain.reStart()
    end

    self.callbackMap["switchedAccount"] = function(params)
        --Logger.log("switchedAccount from callback", "sdk switchedAccount from callback-------->")
        GameMain.reStart()
    end

    self.callbackMap["update_product"] = function(params)
        local charge_product_cfg = ConfigManager:getCfgByName("charge_product")

        self.chargeProductsMap = {}
        for k, v in pairs(charge_product_cfg) do
            for _, productName in pairs(params.products) do
                if v.product_id == productName then
                    self.chargeProductsMap[v.cost] = productName
                    break
                end
            end
        end
    end

    self.m_sdk_helper:init(callbackAction)

    self.callbackMap["sendInfoToPlatformCallBack"] = function (jsonStr)
         Logger.logAlways( "sendInfoToPlatform jsonStr ==" .. jsonStr)
    end

    self.callbackMap["payFailed"] = function (data)
        Logger.logAlways( data, "payFailed")
        if data.why == "pay_unfinish" then
            static_rootControl:closeView("Loading.SmallLoading", "pay_small_loading")
            static_rootControl:closeView("Loading.SmallLoading", "ios_pay_small_loading")
            local payInfoData = Json.decode(data.payInfo)
            local params =
            {
                on_ok_call = function(msg)
                    PayUtil:startPayCommon(payInfoData);
                end,
                no_close_btn = true,
                text = "继续未完成交易" .. payInfoData.goods_name .. " goodsID:" .. payInfoData.goods_id
            }
            static_rootControl:openView("Pops.CommonPop", params, nil, true)

        end
    end

    
end

function M:sdkInit(callback)
    self.callbackMap["sdkInit"] = callback
    self.m_sdk_helper:sdkInit()


end

function M:isLogined(callback)
    self.callbackMap["isLogined"] = callback
    self.m_sdk_helper:isLogined()
end

function M:autoLogin(callback)
    self.callbackMap["autoLogin"] = callback
    self.m_sdk_helper:autoLogin()
end

function M:logIn(callback, params)
    self.callbackMap["logIn"] = callback
    self.m_sdk_helper:logIn(params)
end

function M:logOut(callback)
    --self.callbackMap["logOut"] = callback
    self.m_sdk_helper:logOut()
end

function M:exitGame()
    self.m_sdk_helper:exitGame()
end

function M:listenOnBackPressed(callback)
    self.callbackMap["onBackPressed"] = callback
end

function M:getPlatform(platform_callback)
    self:getOaid()
    self.callbackMap["getPlatform"] = function(data)
        if data and data ~= "" then
            for k, v in pairs(data) do
                if k ~= "func" then
                    M.sdk_params[k] = v
                end
            end
        end
        if self.sdk_params.notch then
            UserDataManager.client_data.is_iphonex = true
        end
        Logger.log(M.sdk_params, "platform ====")
        if platform_callback then
            platform_callback()
        end
    end
    self.sdk_params.applicationId = __Application.identifier
    self.m_sdk_helper:getPlatform()
    self.sdk_params.device = __SystemInfo.deviceName
    self.sdk_params.operatingSystem = __SystemInfo.operatingSystem
    self.sdk_params.cpuType = __SystemInfo.processorType
    self.sdk_params.processorCount = __SystemInfo.processorCount -- cup核心数
    self.sdk_params.GLRender = __SystemInfo.graphicsDeviceName
    self.sdk_params.GLVersion = __SystemInfo.graphicsDeviceVersion
    self.sdk_params.applicationVersion = __Application.version
    self.sdk_params.sysLanguage = __Application.systemLanguage:ToString()
    self.sdk_params.memory = __SystemInfo.systemMemorySize -- 内存
    self.sdk_params.graphicsMemory = __SystemInfo.graphicsMemorySize -- 显存
    self.sdk_params.screenWidth = U3DUtil:Screen_Width()
    self.sdk_params.screenHight = U3DUtil:Screen_Height()
    self.sdk_params.network = U3DUtil:Get_NetWorkMode()
    self.sdk_params.mac = CS.PlatformUtil.GetMacAddress()
    self:getNetworkState(
        function(params)
            self.sdk_params.network = params.data
        end
    )
end

function M:getOaid()

    if SDKUtil.is_oneSDK and self.sdk_params.oa_id then
        return self.sdk_params.oaid
    end 
    
    self.callbackMap["getOaid"] = function(data)
        Logger.log(data, "getOaid ====")
        if data and data ~= "" then
            for k, v in pairs(data) do
                if k ~= "func" then
                    M.sdk_params[k] = v
                end
            end
        end
    end
    self.m_sdk_helper:getOaid()
end

function M:appendPlatformParam(params)
    for k, v in pairs(self.sdk_params) do
        params[k] = tostring(v)
    end
end


function M:onEventRegister()

    if GameUtil:getpPlatform() == "Android" then
        local params = {}
        params.whatInfo = "onEventRegister"
        local info_json = Json.encode(params)
        self.m_sdk_helper:sendInfoToPlatform(info_json)

    end



end

-- import com.bytedance.applog.game.GameReportHelper;
--内置事件: “注册” ，属性：注册方式，是否成功，属性值为：wechat ，true
-- GameReportHelper.onEventRegister("wechat",true);
--内置事件 “支付”，属性：商品类型，商品名称，商品ID，商品数量，支付渠道，币种，是否成功（必传），金额（必传）
--GameReportHelper.onEventPurchase("gift","flower", "008",1,  "wechat","¥", true, 1);

function M:onEventPurchase(info,Success)
    if GameUtil:getpPlatform() == "Android" then
        info.whatInfo = "onEventPurchase"
        info.success = Success
        local info_json = Json.encode(info)
        self.m_sdk_helper:sendInfoToPlatform(info_json)
    end

end



function M:sendExtendInfoSubmit(infotype)

    local serverData = UserDataManager.server_data:getServerData()
    local serverTime = UserDataManager:getServerTime()

    local params = {}
    local serverId = serverData.server --服务器id
    local userData =UserDataManager.user_data
    local uid = userData:getUserStatusDataByKey("uid") --玩家uid
    params.openid = UserDataManager.client_data.openid -- sdk的唯一ID
    params.server_name = tostring(serverData.server_name) -- 服务器名
    params.role_name = UserDataManager.user_data:getUserStatusDataByKey("name") or ""
    params.uid = uid
    params.server_id = tostring(serverId)
    params.role_level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
    params.reg_ts = UserDataManager.reg_ts
    params.infotype = infotype
    params.user_own_coin = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
    params.vip_level = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local guildName = UserDataManager.user_data:getUserStatusDataByKey("guild_name")
    if guildName ~= nil and guildName ~= "" then
        params.partyName = guildName
    else
        params.partyName = "无"
    end
    params.powerNum = UserDataManager.user_data:getUserStatusDataByKey("full_combat") or 0

    params.whatInfo = "extendInfoSubmit"

    local info_json = Json.encode(params)
    self.m_sdk_helper:sendInfoToPlatform(info_json)
end

function M:sendBiDataSubmit(action,action_name,actionResult)

    local serverData = UserDataManager.server_data:getServerData()
    local serverTime = UserDataManager:getServerTime() or 0

     local role_name = UserDataManager.user_data:getUserStatusDataByKey("name") or ""


    if not serverData then
        serverData = {}
        serverData.server = 0
        serverData.server_name = ""
    end
    --String dt = sJson.getString("dt");
    --String gameName = sJson.getString("gameName");

    local params = {}
    local serverId =  serverData.server --服务器id
    local userData =UserDataManager.user_data
    local uid = userData:getUserStatusDataByKey("uid") --玩家uid
    params.openid = UserDataManager.client_data.openid or "" -- sdk的唯一ID
    params.server = tostring(serverData.server_name) -- 服务器名
    params.role_name = UserDataManager.user_data:getUserStatusDataByKey("name") or ""
    params.uid = uid or ""
    params.roleid = uid or ""
    params.role_info = role_name or ""
    params.action = action or ""
    params.action_name = action_name or ""
    params.action_result = actionResult or ""
    params.resVer = GameVersionConfig.GAME_RESOURCES_VERION
    params.dt = TimeUtil.fmtTime(serverTime ,5)
    params.gameName =  "锦绣江湖" ;
    params.server_id = tostring(serverId)
    params.role_level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
    params.reg_ts = UserDataManager.reg_ts

    params.whatInfo = "biSubmit"

    local info_json = Json.encode(params)
    self.m_sdk_helper:sendInfoToPlatform(info_json)
end

function M:sendIOSPayFinish(product_id)

    local params = {}
    params.whatInfo = "payFinish"
    params.product_id = product_id
    local info_json = Json.encode(params)
    self.m_sdk_helper:sendInfoToPlatform(info_json)

end

function M:sendBiDataSubmit(action,action_name,actionResult)

    local serverData = UserDataManager.server_data:getServerData()
    local serverTime = UserDataManager:getServerTime() or 0

     local role_name = UserDataManager.user_data:getUserStatusDataByKey("name") or ""


    if not serverData then
        serverData = {}
        serverData.server = 0
        serverData.server_name = ""
    end
    --String dt = sJson.getString("dt");
    --String gameName = sJson.getString("gameName");

    local params = {}
    local serverId =  serverData.server --服务器id
    local userData =UserDataManager.user_data
    local uid = userData:getUserStatusDataByKey("uid") --玩家uid
    params.openid = UserDataManager.client_data.openid or "" -- sdk的唯一ID
    params.server = tostring(serverData.server_name) -- 服务器名
    params.role_name = UserDataManager.user_data:getUserStatusDataByKey("name") or ""
    params.uid = uid or ""
    params.roleid = uid or ""
    params.role_info = role_name or ""
    params.action = action or ""
    params.action_name = action_name or ""
    params.action_result = actionResult or ""
    params.resVer = GameVersionConfig.GAME_RESOURCES_VERION
    params.dt = TimeUtil.fmtTime(serverTime ,5)
    params.gameName =  "锦绣江湖" ;
    params.server_id = tostring(serverId)
    params.role_level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
    params.reg_ts = UserDataManager.reg_ts

    params.whatInfo = "biSubmit"

    local info_json = Json.encode(params)
    self.m_sdk_helper:sendInfoToPlatform(info_json)
end

function M:isNotch(callback)
    self.callbackMap["isNotch"] = callback
    self.m_sdk_helper:isNotch()
end

function M:getNotice(callback, scene)
    self.callbackMap["getNotice"] = callback
    self.m_sdk_helper:getNotice(scene)
end

function M:agreeUserAgreement(callback)
    self.callbackMap["agreeUserAgreement"] = callback
    self.m_sdk_helper:agreeUserAgreement()
end

function M:pushRegister(account)
    self.m_sdk_helper:PushRegister(account)
end

function M:pushUnRegister()
    self.m_sdk_helper:PushUnRegister()
end

function M:pushSetTag(tag)
    self.m_sdk_helper:PushSetTag(tag)
end

function M:pushDeleteTag()
    self.m_sdk_helper:PushDeleteTag()
end

function M:pushSetAccount(account)
    self.m_sdk_helper:PushSetAccount(account)
end

function M:pushDeleteAccount()
    self.m_sdk_helper:PushDeleteAccount()
end

function M:pushAddLocalNotify(title, content, delay)
    self.m_sdk_helper:PushAddLocalNotify(title, content, delay)
end

function M:pushClearLocalNotify()
    self.m_sdk_helper:PushClearLocalNotify()
end

function M:openUrl(url, callback)
    self.callbackMap["openUrl"] = callback
    self.m_sdk_helper:openUrl(url)
end

function M:pay(callback, goodsInfo)
    if self.chargeProductsMap ~= nil then
        goodsInfo.product_id = self.chargeProductsMap[goodsInfo.cost_key]
    end

    self.callbackMap["pay"] = callback
    local info_json = Json.encode(goodsInfo)
    self.m_sdk_helper:pay(info_json)
end

function M:setCallback(name, func)
    self.callbackMap[name] = func
end

--一些特有的sdk功能调用，比如字节得查询上架商品，其他的sdk没有，通过字符串调用省的定义太多接口函数
function M:handleGameEvent(eventName, params)
    local strParam = params and Json.encode(params) or ""
    return self.m_sdk_helper:onGameEvent(eventName, strParam)
end


function M:callSdkFunc(funcName, params, callback)
    if callback then

        -- find tag name
        local _call_back_name = funcName .. "_callback_"
        local tag_id = 1
        local _call_back_tag = _call_back_name .. tag_id

        while self.callbackMap[_call_back_tag] do
            tag_id = tag_id + 1
            _call_back_tag = _call_back_name .. tag_id
        end

        local _callback_handle = function(rst_param)
                rst_param.func = nil
                callback(rst_param)

                self.callbackMap[_call_back_tag] = nil
        end

        self.callbackMap[_call_back_tag] = _callback_handle

        params["__call_back"] = _call_back_tag
    end

    return SDKUtil:handleGameEvent(funcName, params)
end
function M:callCSFuncByName(funcName ,params, callback)
    if  callback then
        self.callbackMap[funcName] = callback
    end
    
    self.m_sdk_helper:onGameEvent(funcName, params)

end
-- showType 1 == login
-- showType 2 == game
function M:antiAddiction(showType, aa_rst_callback)
    local function __antiAddTest(isForceGetAARst)
        local function _popShowMsg(titleTxt, msgText, btnTxt, end_rst)
            local params = {
                on_ok_call = function(msg)
                    aa_rst_callback(end_rst)
                end,
                no_close_btn = true,
                tow_close_btn = false,
                ok_text = btnTxt,
                text = msgText,
                title = titleTxt,
                custom_text_height = 180,
            }

            if not end_rst then
                params.ok_end_timer = 3
            end

            static_rootControl:openView("Pops.CommonPop", params)

        end

        local function _popAuthView(fail_cb)
            if not self.callbackMap["realname_end"] then
                self.callbackMap["realname_end"] = function(param)
                    if param.success then
                        __antiAddTest(false)
                    else
                        fail_cb()
                    end
                end
            end
            self.m_sdk_helper:onGameEvent("show_realname","")
        end

        self.m_sdk_helper:fetchAntiAddictionInfo(
            isForceGetAARst,
            function(sdkRst, message)
                Logger.log("AntiAddiction rst: " .. sdkRst .. " Msg: " .. message)

                if sdkRst == "Ignore" then
                    aa_rst_callback(true)
                elseif sdkRst == "MinorRemind" then
                    -- 未成年用户即将达到单日累计在线时长限制
                    _popShowMsg(
                        Language:getTextByKey("sdk_txt_002"),
                        -- Language:getTextByKey("sdk_txt_011"),
                        message,
                        Language:getTextByKey("sdk_txt_013"),
                        true
                    )
                elseif sdkRst == "MinorLimit" then
                    --MinorLimit 未成年用户达到单日累计在线时长限制
                    _popShowMsg(
                        Language:getTextByKey("sdk_txt_002"),
                        -- Language:getTextByKey("sdk_txt_014"),
                        message,
                        Language:getTextByKey("sdk_txt_001"),
                        false
                    )
                elseif sdkRst == "MinorCurfew" then
                    --MinorCurfew 未成年用户宵禁
                    _popShowMsg(
                        Language:getTextByKey("sdk_txt_002"),
                        -- Language:getTextByKey("sdk_txt_012"),
                        message,
                        Language:getTextByKey("sdk_txt_001"),
                        false
                    )
                elseif sdkRst == "ForceOffline" then
                    --ForceOffline 强制下线（默认策略无此场景）
                    --ForceOffline 强制下线（默认策略无此场景）
                elseif sdkRst == "RemindOffline" then
                    --RemindOffline 提醒玩家即将被下线（默认策略无此场景）
                elseif sdkRst == "VisitorRemind" then
                    --VisitorRemind 游客（未实名）用户即将达到在线时长限制
                    local params = {
                        on_ok_call = function(msg)
                            _popAuthView(
                                function()
                                    aa_rst_callback(true)
                                end
                            )
                        end,
                        on_cancel_call = function(msg)
                            aa_rst_callback(true)
                        end,
                        ok_text = Language:getTextByKey("sdk_txt_003"),
                        cancel_text = Language:getTextByKey("sdk_txt_005"),
                        no_close_btn = false,
                        tow_close_btn = true,
                        -- text = Language:getTextByKey("sdk_txt_015"),
                        text = message,
                        title = Language:getTextByKey("sdk_txt_002"),
                        custom_text_height = 160
                    }

                    static_rootControl:openView("Pops.CommonPop", params)
                elseif sdkRst == "VisitorLoginTips" then
                    --     end
                    -- )
                    --VisitorLoginTips 游客（未实名）用户登录成功后提醒
                    -- call m_sdk_helper:fetchAntiAddictionInfo only for refresh antiaddictioninfo state
                    -- self.m_sdk_helper:fetchAntiAddictionInfo(
                    --     false,
                    --     function(sdkRst2, message2)
                    local params2 = {
                        on_ok_call = function(msg)
                            _popAuthView(
                                function()
                                    aa_rst_callback(true)
                                end
                            )
                        end,
                        on_cancel_call = function(msg)
                            aa_rst_callback(true)
                        end,
                        ok_text = Language:getTextByKey("sdk_txt_003"),
                        cancel_text = Language:getTextByKey("sdk_txt_009"),
                        no_close_btn = false,
                        tow_close_btn = true,
                        -- text = Language:getTextByKey("sdk_txt_010"),
                        text = message,
                        title = Language:getTextByKey("sdk_txt_002"),
                        custom_text_height = 160
                    }
                    StatisticsUtil:doPoint("realNameTips") --实名认证提示打点
                    static_rootControl:openView("Pops.CommonPop", params2)
                elseif sdkRst == "VisitorLimit" then
                    --VisitorLimit 游客（未实名）用户达到在线时长限制
                    local params1 = {
                        on_ok_call = function(msg)
                            _popAuthView(
                                function()
                                    Logger.log("params1--VisitorLimit 游客（未实名）用户达到在线时长限制")
                                    aa_rst_callback(false)
                                    -- static_rootControl:setOnceTimer(1, __antiAddTest(true))
                                end
                            )
                        end,
                        on_cancel_call = function(msg)
                            aa_rst_callback(false)
                        end,
                        no_close_btn = false,
                        tow_close_btn = true,
                        ok_text = Language:getTextByKey("sdk_txt_003"),
                        -- "实名认证",
                        cancel_text = Language:getTextByKey("sdk_txt_004"),
                        --"退出登录",
                        -- text = Language:getTextByKey("sdk_txt_016"),

                        text = message,
                        title = Language:getTextByKey("sdk_txt_002"),
                        --"提示"
                        custom_text_height = 180
                    }

                    static_rootControl:openView("Pops.CommonPop", params1)
                elseif sdkRst == "VisitorCurfew" then
                    --VisitorCurfew 游客（未实名）用户宵禁（默认策略无此场景）
                elseif sdkRst == "MinorLoginTips" then
                    --MinorLoginTips 未成年用户登录成功后提醒
                    -- _popShowMsg(
                    --     Language:getTextByKey("sdk_txt_002"),
                    --     -- Language:getTextByKey("sdk_txt_008"),
                    --     message,
                    --     Language:getTextByKey("sdk_txt_005"),
                    --     true
                    -- )
                    aa_rst_callback(true)

                    -- local params3 = {
                    --     on_ok_call = function(msg)
                    --         aa_rst_callback(true)
                    --     end,
                    --     on_cancel_call = function(msg)
                    --         SDKUtil:openUrl(
                    --             "https://www.nvsgames.cn/anti-addiction/teenage_rules.html",
                    --             function()
                    --                 aa_rst_callback(true)
                    --             end
                    --         )
                    --     end,
                    --     no_close_btn = false,
                    --     tow_close_btn = true,
                    --     ok_text = Language:getTextByKey("sdk_txt_005"),
                    --     cancel_text = Language:getTextByKey("sdk_txt_detail"),
                    --     text = message,
                    --     title = Language:getTextByKey("sdk_txt_002"),
                    --     custom_text_height = 160
                    -- }
                    -- static_rootControl:openView("Pops.CommonPop", params3)
                end
            end
        )
    end
    __antiAddTest(false)
end

-- 查询购买项是否在SDK清单中
function M:isChargeItemValid(chargeId)
    if self.chargeProductsMap == nil then
        -- sdk没有上架货物清单，默认全部可用
        return true
    else
        return self.chargeProductsMap[chargeId] ~= nil
    end
end

-----------------------------------------推送展示设置-------------------------------
function M:PushRemoveAll()
    self.m_sdk_helper:PushRemoveAll()
end

function M:PushRemoveToIdentifier(identifier)
    self.m_sdk_helper:PushRemoveToIdentifier(identifier)
end

function M:PushMonthlyRepeat(title, content, identifier, day, hout, minute, second)
    self.m_sdk_helper:PushMonthlyRepeat(title, content, identifier, day, hout, minute, second)
end

function M:PushMonthlyRepeat(title, content, identifier, week, weekday, hout, minute, second)
    self.m_sdk_helper:PushMonthlyRepeat(title, content, identifier, week, weekday, hout, minute, second)
end

function M:PushWeeklyRepeat(title, content, identifier, weekday, hout, minute, second)
    self.m_sdk_helper:PushWeeklyRepeat(title, content, identifier, weekday, hout, minute, second)
end

function M:PushDailyRepeat(title, content, identifier, hout, minute, second)
    self.m_sdk_helper:PushDailyRepeat(title, content, identifier, hout, minute, second)
end

function M:PushOneTime(title, content, identifier, year, month, day, hout, minute, second)
    self.m_sdk_helper:PushOneTime(title, content, identifier, year, month, day, hout, minute, second)
end

function M:PushIntervalRepeat(title, content, identifier, time, isRepeat)
    self.m_sdk_helper:PushIntervalRepeat(title, content, identifier, time, isRepeat)
end

function M:GetInvitation(url, callback)
    self.callbackMap["shareUrl"] = callback
    self.m_sdk_helper:GetInvitation(url)
end

function M:CheckForceUpgrade(callback)
    self.callbackMap["NeedUpgrade"] = callback
    self.m_sdk_helper:CheckForceUpgrade(true)
end

function M:StartCustomUpgrade()
    self.m_sdk_helper:StartCustomUpgrade()
end

function M:onCancelBtnClick()
    self.m_sdk_helper:onCancelBtnClick()
end

function M:SdkDeviceIsEmulator(callback)
    self.callbackMap["SdkDeviceIsEmulator"] = callback
    self.m_sdk_helper:SdkDeviceIsEmulator()
end

function M:IsCharging(callback)
    self.callbackMap["getCharging"] = callback
    self.m_sdk_helper:getCharging()
end

function M:IsHead(callback)
    self.callbackMap["getHead"] = callback
    self.m_sdk_helper:getHead()
end

function M:getScreenBrightness(callback)
    self.callbackMap["getScreenBrughtness"] = callback
    self.m_sdk_helper:getScreenBrughtness()
end

function M:setScreenBrightness(btightness)
    self.m_sdk_helper:setScreenBrughtness(btightness)
end

function M:getNetworkState(callback)
    self.callbackMap["getNetworkState"] = callback
    self.m_sdk_helper:getNetworkState()
end

function M:getScreenType(callback)
    self.callbackMap["getScreenType"] = callback
    self.m_sdk_helper:getScreenType()
end

function M:getElectricity(callback)
    self.callbackMap["getElectricity"] = callback
    self.m_sdk_helper:getElectricity()
end

function M:RegisterExperiment(key, owner, description, defaultValue, callback)
    self.callbackMap["RegisterExperiment"] = callback
    self.m_sdk_helper:RegisterExperiment(key, owner, description, defaultValue)
end

function M:GetExperimentValue(key, isExposure, callback)
    self.callbackMap["GetExperimentValue"] = callback
    self.m_sdk_helper:GetExperimentValue(key, isExposure)
end

function M:RegisterAccountStatusChangedListener(callback)
    self.callbackMap["logoutChannel"] = callback
    self.m_sdk_helper:logoutChannel()
end

function M:SdkOnExit(callback)
    self.callbackMap["SdkOnExit"] = callback
    self.m_sdk_helper:SdkOnExit()
end

function M:CreateNewRoleUpload(roleData)

    self:sendExtendInfoSubmit("createRole")

    self.m_sdk_helper:CreateNewRoleUpload(roleData)
end

function M:RoleLevelUpload(roleData)
    self:sendExtendInfoSubmit("levelUp")
    self.m_sdk_helper:RoleLevelUpload(roleData)
end

function M:EnterGameUpload(roleData)
    self:sendExtendInfoSubmit("enterServer")
    self.m_sdk_helper:EnterGameUpload(roleData)
end

function M:RoleExitUpload(roleData)
    self.m_sdk_helper:RoleExitUpload(roleData)
end

function M:SdkCheckRealNameResult(callback)
    self.callbackMap["SdkCheckRealNameResult"] = callback
    self.m_sdk_helper:SdkCheckRealNameResult()
end

function M:getFetchZonesList(callback, gameVersion)
    self.callbackMap["getFetchZonesList"] = callback
    self.m_sdk_helper:getFetchZonesList(gameVersion)
end

function M:getFetchRolesList(callback)
    self.callbackMap["getFetchRolesList"] = callback
    self.m_sdk_helper:getFetchRolesList()
end

function M:getFetchZonesAndRolesList(callback, gameVersion)
    self.callbackMap["getFetchZonesAndRolesList"] = callback
    self.m_sdk_helper:getFetchZonesAndRolesList(gameVersion)
end

function M:getPingServerList(callback)
    self.callbackMap["getPingServerList"] = callback
    self.m_sdk_helper:getPingServerList()
end

function M:Getdid(callback)
    self.callbackMap["GetDid"] = callback
    self.m_sdk_helper:GetDid()
end

--gpm开始场景
function M:OnSceneStart(scenceName)
    self.m_sdk_helper:OnSceneStart(scenceName)
end

--gpm场景加载完成之后
function M:OnSceneLoadFinish()
    self.m_sdk_helper:OnSceneLoadFinish()
end

--gpm场景结束
function M:OnSceneEnd()
    self.m_sdk_helper:OnSceneEnd()
end

--判断接口是否可用
function M:SDKIsAvailable(callback,apiName)
    self.callbackMap["sdkIsAvailable"] = callback
    if self.m_sdk_helper.SDKIsAvailable then
        self.m_sdk_helper:SDKIsAvailable(apiName)
    else
        return false
    end
end

---------九尾

--监听九尾消息
function M:listenNativeNotification(callback)
    if self.m_sdk_helper.listenNativeNotification then
        self.callbackMap["listenNativeNotification"] = callback
        self.m_sdk_helper:listenNativeNotification()
    end
end

--初始化角色信息
function M:updateGameConfig(roleId,roleName,serverId)
    if self.m_sdk_helper.updateGameConfig then
        self.m_sdk_helper:updateGameConfig(roleId,roleName,serverId)
    end
end

--设置字体
function M:SetGameFont(fontName,font)
    if self.m_sdk_helper.SetGameFont then
        self.m_sdk_helper:SetGameFont(fontName,font)
    end
end

--设置九尾页面游戏父节点 parentGoName(string) or parentGo(GameObject)
function M:SetGameGoParent(parentGoName)
    if self.m_sdk_helper.SetGameGoParent then
        self.m_sdk_helper:SetGameGoParent(parentGoName)
    end
end

--上传游戏内数据接口
function M:SetGameData(gameData)
    if self.m_sdk_helper.SetGameData then
        self.m_sdk_helper:SetGameData(gameData)
    end
end

--获取活动信息
function M:openFaceVerify(callback,type)
    if self.m_sdk_helper.openFaceVerify then
        self.callbackMap["openFaceVerify"] = callback
        self.m_sdk_helper:openFaceVerify(type)
    end
end

--打开活动
function M:openPage(callback,activityUrl,inGameId)
    if self.m_sdk_helper.openPage then
        self.callbackMap["openPage"] = callback
        self.m_sdk_helper:openPage(activityUrl,inGameId)
    end
end

--打开活动
function M:openPagehasParentGo(callback,activityUrl,inGameId,panelParentGo)
    if self.m_sdk_helper.openPage then
        self.callbackMap["openPage"] = callback
        self.m_sdk_helper:openPage(activityUrl,inGameId,panelParentGo)
    end
end

--隐藏页面
function M:hidePage(callback,windowId)
    if self.m_sdk_helper.hidePage then
        self.callbackMap["hidePage"] = callback
        self.m_sdk_helper:hidePage(windowId)
    end
end

--显示页面
function M:showPage(callback,windowId)
    if self.m_sdk_helper.showPage then
        self.callbackMap["showPage"] = callback
        self.m_sdk_helper:showPage(windowId)
    end
end

--关闭页面
function M:closePage(callback,windowId)
    if self.m_sdk_helper.closePage then
        self.callbackMap["closePage"] = callback
        self.m_sdk_helper:closePage(windowId)
    end
end

--给九尾发送消息
function M:sendMessageToPage(callback,windowId,eventName,eventMessage)
    if self.m_sdk_helper.sendMessageToPage then
        self.callbackMap["sendMessageToPage"] = callback
        self.m_sdk_helper:sendMessageToPage(windowId,eventName,eventMessage)
    end
end

--获取当前打开的页面
function M:getRNPages(callback)
    if self.m_sdk_helper.getRNDebug then
        self.callbackMap["getRNPages"] = callback
        self.m_sdk_helper:getRNDebug()
    end
end

--关闭所有页面
function M:closeAllPages()
    if self.m_sdk_helper.closeAllPages then
        self.m_sdk_helper:closeAllPages()
    end
end

--根据场景获取活动红点数据 type(string  类型)
function M:queryActivityNotifyDataByType(callback,type)
    if self.m_sdk_helper.queryActivityNotifyDataByType then
        self.callbackMap["queryActivityNotifyDataByType"] = callback
        self.m_sdk_helper:queryActivityNotifyDataByType(type)
    end
end

--根据场景获取活动红点数据 activityId(string 活动id)
function M:queryActivityNotifyDataById(callback,activityId)
    if self.m_sdk_helper.queryActivityNotifyDataById then
        self.callbackMap["queryActivityNotifyDataById"] = callback
        self.m_sdk_helper:queryActivityNotifyDataById(activityId)
    end
end

--接收九尾发送的通知消息
function M:sendMessageToGumiho(message)
    if self.m_sdk_helper.sendMessageToGumiho then
        self.m_sdk_helper:sendMessageToGumiho(message)
    end
end

--打开debug
function M:setRNDebug(isEnable)
    if self.m_sdk_helper.setRNDebug then
        self.m_sdk_helper:setRNDebug(isEnable)
    end
end

--查询debug是否打开
function M:getRNDebug(callback)
    if self.m_sdk_helper.getRNDebug then
        self.callbackMap["getRNDebug"] = callback
        self.m_sdk_helper:getRNDebug()
    end
end

--打开debug页面
function M:showTestPage(callback)
    if self.m_sdk_helper.showTestPage then
        self.callbackMap["showTestPage"] = callback
        self.m_sdk_helper:showTestPage()
    end
end

--是否接了乐变SDK
function M:getLeBianSDK()
    if self.m_sdk_helper.IsLeBianSDKAvailable then
        return self.m_sdk_helper:IsLeBianSDKAvailable()
    end
    return false
end

--通过乐变SDK下载分包资源
function M:tryDownloadResourceWithLeBianSDK(callback)
    if self:getLeBianSDK() then
        if self.m_sdk_helper.LeBianDownloadRes then
            self.callbackMap["LeBianDownloadRes"] = callback
            self.m_sdk_helper:LeBianDownloadRes()
        end
    end
end


function  M:HttpRequestBiMsg()

    -- local cb = handler(self, function(_, success, dataStr, tag)
    --     Logger.logAlways( "platformAccess dataStr ==" .. dataStr)
    -- end)
    -- __HttpRequest:SendMsg("www.baidu.com", "_regular_", "", "POST", 10, cb)

end

function M:sendBitrack(actionName)

    local params = {}

    params.action = "dudai_client"
    params.platform =  SDKUtil.sdk_params.OSPlatform or ""
    params.sdkver = SDKUtil.sdk_params.sdkver
    params.deviceid = SDKUtil.sdk_params.deviceid
    params.imei = SDKUtil.sdk_params.imei
    params.idfv = SDKUtil.sdk_params.idfv
    params.gaid = SDKUtil.sdk_params.gaid
    params.androidid = SDKUtil.sdk_params.androidid
    params.oaid = SDKUtil.sdk_params.oaid
    params.fchannel = SDKUtil.sdk_params.fchannel
    params.channel = SDKUtil.sdk_params.subChannel
    params.uid = SDKUtil.sdk_params.uid or ""
    params.applicationId = SDKUtil.sdk_params.applicationId

    params.roleid = ""
    params.server = ""

    if UserDataManager.server_data then
        local serverData = UserDataManager.server_data:getServerData()
        if serverData then
            params.server =  tostring(serverData.server)
        end
    end



    local userData = UserDataManager.user_data
    if userData then
        local uid = userData:getUserStatusDataByKey("uid") --玩家uid
        params.roleid = uid
    end


    params.action_name = actionName
    params.game = "JinXiuJiangHu"
    params.ver = SDKUtil.sdk_params.ver

    Logger.logAlways(params,"params bitrack")
    local url = NetUrl.getUrlForKey("bitrack")

    local newkey = url .. "&__ts=" .. tostring(os.time())
    NetWork:httpRequest(
            function()
            end ,  newkey ,GlobalConfig.POST ,  params ,  "bitrack",   1, true,
            nil,  nil,1)

end


return M
