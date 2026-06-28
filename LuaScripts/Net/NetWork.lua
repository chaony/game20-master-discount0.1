------------------- NetWork

local M = {
    m_requestMap = {},
    m_request_count = 0,
    m_server_request_count = 1024,
    m_request_list = {},
    m_cur_request = nil,
}

local HttpRequest = CS.wt.framework.HttpRequest.Inst
HttpRequest.vcd = GameVersionConfig.vcd or 1
local __RETRY_COUNT = 1
local __RETRY_TIME = 1     -- 多长时间后重试, 单位秒
local __DEFAULT_TIMEOUT = 5
G_GUIDE_FORCE_NET_COMPLETE = false -- 标记开始新手引导，在此期间，需要等到数据恢复后再继续 

function M:resetServerRequestCount()
    self.m_server_request_count = 1024
end

function M:closeLoading(request)
    local loadingFlag = request and request.loadingFlag
    local can_close = self:canCloseLoading()
    if loadingFlag ~= 0 and can_close then
        EventDispatcher:registerTimeEvent(
            "close_net_loading_" .. request.tag_sign_key,
            function()
                static_rootControl:closeView("Loading.SmallLoading", "net_work_small_loading")
                static_rootControl:closeView("Loading.BigLoading", "net_work_big_loading")
            end,
            0.016,
            0.016
        )
    end
end

function M:handleCallback(request, status_code)
    if request.returnFlag and type(request.callback) == "function" then
        request.callback(nil, request.tag, tostring(status_code or ""), request.pop_failed_tips_count)
    end
end

function M:handleNullData(data, request, error_key)
    if not request.showTips then
        self:handleCallback(request)
    else
        self:showRequestFailedTip(function()
            self:handleCallback(request)
        end, Language:getTextByKey(error_key or "new_str_0009"))
    end
end

function M:handleDownloadGame(data, request)
    local updateUrl = data.url
    if updateUrl == nil then return end
    local params =
    {
        on_ok_call = function(msg)
            -- TODO : 打开下载链接 暂时重新登录
            GameMain.reStart()
        end,   
        no_close_btn = true,
        text = data.msg or Language:getTextByKey("new_str_0008"),
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

--- 更新配置提示
function M:showConfigChangeTip(data, request)
    local tips = data.config_refresh_text or Language:getTextByKey("new_str_0479")
    local params =
    {
        on_ok_call = function(msg)
            GameMain.reStart()
        end,
        no_close_btn = true,
        text = tips,
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

-- 添加配置更新的处理
function M:handleConfigChange(data, request)
    local new_version_count = data.version_count or 0
    local version_count = UserDataManager.local_data:getLocalDataByKey("version_count", 0)
    if new_version_count == 0 or new_version_count > version_count then
        local all_config_version = data.all_config_version or ""
        local new_data = data.data
        if new_data.config_refresh and tonumber(new_data.config_refresh) == 1 then -- 需要更新配置
            local str = U3DUtil:PlayerPrefs_GetString("all_config_version", "")
            if str ~= nil and str ~= all_config_version then
                self:showConfigChangeTip(new_data, request)
            end
        end
    end
end

function M:skipPopFailedTipsGoMain(request, clean_request_flag)
    if request.showTips then
        if request.returnFlag and not G_GUIDE_FORCE_NET_COMPLETE and static_rootControl.m_model:getName() == "Main" then
            if request.pop_failed_tips_count > 2 then
                if clean_request_flag then
                    self:cleanRequestByTag(request.tag_sign_key)
                end
                static_rootControl:closeAllViewPop()
                return true
            end
        end
        request.pop_failed_tips_count = request.pop_failed_tips_count + 1
    end
    return false
end

function M:handleStatusError(data, request, error_key)
    if not request.showTips then
        self:handleCallback(request, data.status)
    else
        local error_msg = error_key or data.msg
        self:showNetErrorTip(function()
            self:handleCallback(request, data.status)
        end, error_msg)
    end
end

function M:handleStatusErrorTips(data, request)
    if request.showTips then
        local error_msg = data.msg or "new_str_0697"
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(error_msg), delay_close = 2})
    end
end

function M:showNetErrorTip(callback, error_msg)
    local params =
    {
        on_ok_call = function(msg)
            if type(callback) == "function" then
                callback()
            end
        end,   
        no_close_btn = true,
        text = Language:getTextByKey(error_msg or "new_str_0011")
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:handleServerNotOpen(data, request)
    local params =
    {
        on_ok_call = function(msg)
            if static_rootControl.m_model:getName() == "Main" then
                GameMain.reStart()
            else
                self:handleCallback(request, data.status)
            end
        end,
        no_close_btn = true,
        text = data.msg or Language:getTextByKey("new_str_0010")
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:rewardTips(data)
    if type(data) == "table" then
        local delay_open = 0
        for k,v in pairs(data) do
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(v), delay_open = delay_open, delay_close = 2})
            delay_open = delay_open + 1
        end
    else
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(data), delay_close = 2})
    end
end

function M:handleNetWorkFailed(net_data, request, response_code)
    if response_code == 404 or GameVersionConfig.Debug then
        Logger.logErrorAlways(request.url)
    end
    local function doRetry()
        request.retry = (request.retry or 0) + 1        -- 记录重试次数
        self.m_cur_request = nil
        self:httpRequestBase(request)
    end
    local net_type = GameUtil:getNetworkReachability()
    if net_type ~= "nil" and request.retry_count > 0 and response_code ~= 404 and response_code ~= 500 then   -- 有网络并且有重试次数等待响应
        request.retry_count = request.retry_count - 1
        local retry_time = __RETRY_TIME + math.random(0,10)*0.2
        EventDispatcher:registerTimeEvent("tryAgain", doRetry, retry_time, retry_time)
    elseif (G_GUIDE_FORCE_NET_COMPLETE or response_code == 0) and request.showTips and request.tag ~= "portal_server_address_url" then   -- 有新手引导或未知的错误码，必须获取数据
        local function delayCallFunc()
            if self:skipPopFailedTipsGoMain(request, true) then
                return
            end
            request.retry_count = request.backup_retry_count or __RETRY_COUNT
            static_rootControl:closeView("Loading.SmallLoading", "net_work_small_loading")
            static_rootControl:closeView("Loading.BigLoading", "net_work_big_loading")
            local function tipsCallback()
                if request.loadingFlag == 1 then
                    static_rootControl:openView("Loading.SmallLoading",{delay_show = request.delayShowLoading or 2}, "net_work_small_loading")
                elseif request.loadingFlag == 2 then
                    static_rootControl:openView("Loading.BigLoading",{delay_show = request.delayShowLoading}, "net_work_big_loading")
                end
                doRetry()
            end
            self:showRequestFailedTip(tipsCallback, net_data, response_code)
        end
        EventDispatcher:registerTimeEvent("net_work_delay_call_func_timer", delayCallFunc, 0.5, 0.5)
        self:switchUrl(request)
    else
        self:closeLoading(request)
        self:cleanRequestByTag(request.tag_sign_key)
        self:switchUrl(request)
        local showTips = request.showTips
        if not showTips then -- 不需要弹框提示
            self:handleCallback(request, response_code)
        else
            if self:skipPopFailedTipsGoMain(request, false) then
                return
            end
            self:showRequestFailedTip(function()
                self:handleCallback(request, response_code)
            end, net_data, response_code)
        end
    end
end

function M:switchUrl(request)
    if request then
        local url = request.url
        if url then
            local before_url = nil
            local new_url = nil
            local start_idx, _ = string.find(url, "/login/?")
            if start_idx then
                before_url = GameVersionConfig.MASTER_URL
                UserDataManager.server_data:switchMasterUrl()
                new_url = GameVersionConfig.MASTER_URL
            else
                before_url = GameVersionConfig.SERVICE_URL
                UserDataManager.server_data:switchDomainUrl()
                new_url = GameVersionConfig.SERVICE_URL
            end
            if before_url and new_url and before_url ~= new_url then
                self:replaceUrl(request, before_url, new_url)
                for k,v in ipairs(self.m_request_list) do
                    self:replaceUrl(v, before_url, new_url)
                end
            end
        end
    end
end

function M:replaceUrl(request, before_url, new_url)
    if request and before_url and new_url and before_url ~= new_url then
        local start_index, end_index = string.find(request.url, before_url, 1, true)
        if start_index == 1 then
            request.url = new_url .. string.sub(request.url, end_index + 1)
        end
    end
end

function M:showRequestFailedTip(callback, error_msg, response_code)
    local error_msg = error_msg or Language:getTextByKey("new_str_0004")
    if error_msg == "is_http_error" then
        error_msg = Language:getTextByKey("new_str_0245")
    elseif error_msg == "is_network_error" then
        error_msg = Language:getTextByKey("update_str_0005")
    elseif error_msg == "is_http_request_time_out" then
        error_msg = Language:getTextByKey("update_str_0010")
    end
    if response_code then
        error_msg = error_msg .. string.format("{%d}", response_code)
    end
    local params = {
        text = error_msg,
        on_ok_call = callback,   
        on_cancel_call = callback,
    }
    static_rootControl:openView("Pops.CommonPop", params, "netFailed", true)
end

function M:cleanRequestByTag(tag)
    self.m_requestMap[tag] = nil
    self.m_cur_request = nil
    self:httpRequestBase()
end

-- 网络回调处理
function M:httpResponseHander(success, net_data, tag_sign_key, response_code)
    local request = self.m_requestMap[tag_sign_key]
    if success then -- 成功
        local tag = request.tag
        self:closeLoading(request)
        self:cleanRequestByTag(tag_sign_key)
        if request.ingnoreState then
            request.callback(net_data, tag)
            return
        end
        local tag_tab = string.split(tag_sign_key, "##")
        local first_value = tag_tab[1]
        if request.method == GlobalConfig.POST then
            local crypto_url_value = NetUrl.getCryptoUrlValue(first_value)
            local temp_data = nil
            if crypto_url_value == 1 then
                temp_data = UserDataManager.client_data:loginDecryptBase64StringToString(net_data)
            elseif crypto_url_value == 2 then
                -- 不做解密处理
                temp_data = net_data
            else
                temp_data = UserDataManager.client_data:decryptBase64StringToString(net_data)
            end
            if temp_data == nil then
                self:handleNullData(net_data, request, "new_str_0537")
                return
            end
            net_data = temp_data
        end
        
        local data = Json.decode(net_data)
        if not data then
            self:handleNullData(net_data, request)
            return
        end
        -- 客户端升级提示
        local client_upgrade = data.data and data.data.client_upgrade
        if client_upgrade then  -- 客户端升级
            self:handleDownloadGame(client_upgrade, request)
            return
        end
        
        local status = tostring(data.status)
        if data.ec ~= nil then
            status = tostring(data.ec)
        end
        if status == "0" or status == "ok" then  --数据正常
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {event="net_data_back",data = data, tag = tag})
            -- 响应callback
            if type(request.callback) == "function" then
                request.callback(data.data, tag)
            else
                Logger.log("not callback func => " .. tostring(tag))
            end
            self:handleConfigChange(data, request)
            if data.data.reward and data.data.reward.reward_full_tips then
                self:rewardTips(data.data.reward.reward_full_tips)
            end
        elseif status == "error_1024" or status == "28012" then -- 服务器尚未开启
            self:handleServerNotOpen(data, request)
        elseif status == "15003"  then --打公会boss期间被踢出公会
            SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
            static_rootControl:closeAllViewPop()
            self:showNetErrorTip(nil, data.msg)
        elseif status == "58009"  then --奇门遁甲战斗地块变化
            self:showNetErrorTip(function()
                local param = {event="net_data_back",data = data, tag = tag, status = status}
                static_rootControl:updateMsg("change_scene", param , "QiMenDunJia.QiMenDunJiaMain")
                local not_close_tab = {["Main.TotalWorld"] = 1, ["QiMenDunJia.QiMenDunJiaMain"] = 1}
                static_rootControl:closeAllViewPop(not_close_tab)
            end, data.msg)
        else
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {event="net_data_back",data = data, tag = tag, status = status})
            -- 发生的情况是和服务器数据不一致时需要更新
            local data_sync = data.data_sync
            if data_sync then
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {event="net_data_sync",data = data_sync, tag = tag})
            end
            if self:skipPopFailedTipsGoMain(request, false) then
                return
            end
            if string.judgeNumString(status) then
                local status_num = tonumber(status)
                if status_num >= 1000 and status_num <= 1499 then -- 活动过期错误码区间
                    self:showNetErrorTip(function()
                        static_rootControl:closeAllViewPop()
                    end, data.msg)
                elseif status_num >= 1500 and status_num <= 1999 then -- 统一错误码区间提示
                    self:handleServerNotOpen(data, request)
                elseif status_num < 0 then
                    self:handleStatusErrorTips(data, request)
                    self:handleCallback(request, status)
                elseif status_num == 19058 then
                    local params =
                    {
                        no_close_btn = true,
                        text = Language:getTextByKey(data.msg or "new_str_0011")
                    }
                    static_rootControl:openView("Pops.CommonPop", params, nil, true)
                    --GameUtil:lookInfoTips(static_rootControl, {msg = data.msg, delay_close = 2})
                    self:handleCallback(request, status)
                else
                    local flag = QuickOpenFuncUtil:serverCostsTips(status_num)
                    if not flag then
                        self:handleStatusError(data, request)
                    else
                        self:handleCallback(request, status)
                    end
                end
            else
                -- 再提示报错
                local start_index, end_index = string.find(status, "item_")
                if start_index then
                    local item_id = string.sub(status, end_index + 1)
                    if string.judgeNumString(item_id) then
                        local flag = QuickOpenFuncUtil:serverItemCostsTips(item_id)
                        if not flag then
                            self:handleStatusError(data, request, "compass_str_002")
                        else
                            self:handleCallback(request, status)
                        end
                    else
                        self:handleStatusError(data, request, "compass_str_002")
                    end
                else
                    self:handleStatusError(data, request)
                end
            end

        end


        if first_value ~= "login_server" and first_value ~= "hope_report" then
            self:hopeHandle(data.data)
        end
    else -- 网络请求失败
        self:handleNetWorkFailed(net_data, request, response_code)
    end
end

function M:delayCheckHope()
    if self.delay_check_hope_data then
        self:hopeHandle(self.delay_check_hope_data)
        self.delay_check_hope_data = nil
    end
end

local __hope_types = {[1] = 1, [2] = 2, [3] = 3}

-- 中控防沉迷
function M:hopeHandle(data, callback)
    local hope = data and data.hope
    if hope and hope.ret == 0 then
        local in_battle_flag = static_rootControl and static_rootControl:hasChild("GamePanel")
        if in_battle_flag and __hope_types[hope.type or 0] ~= nil then
            -- 战斗中不弹出防沉迷，需要在战斗结算处理
            if callback ~= nil then
                callback()
            end
            self.delay_check_hope_data = data
            return
        end
        if hope.type == 1 then -- 弹提示框
            local params =
            {
                on_ok_call = function(msg)
                    if callback ~= nil then
                        callback()
                    end
                end,
                no_close_btn = true,
                title = hope.title,
                text = hope.msg,
            }
            static_rootControl:openView("Pops.PreventionAddictionPop", params)
            GameUtil:sendHopeReport(hope)
        elseif hope.type == 2 then -- 强制下线
            static_rootControl:closeView("Pops.PreventionAddictionPop", nil, false)
            local params =
            {
                on_ok_call = function(msg)
                    GameMain.reStart()
                end,
                no_close_btn = true,
                title = hope.title,
                text = hope.msg,
            }
            static_rootControl:openView("Pops.PreventionAddictionPop", params)
            GameUtil:sendHopeReport(hope)
        elseif hope.type == 3 then -- 弹web页
            if callback ~= nil then
                callback()
            end
            local params = {}
            params.url = hope.url
            params.show_titlebar = 0
            params.show_title = 0
            params.buttons = {}
            if hope.modal == 0 then
                params.buttons.buttonId = 1
                params.buttons.name = Language:getTextByKey("new_str_0545")
                params.action = 0
            end
            local jsonStr = Json.encode(params)
            Logger.log(jsonStr, "OpenPrajnaWebView jsonStr ===")
            CS.WTMSDKPrajna.OpenPrajnaWebView(jsonStr)
            GameUtil:sendHopeReport(hope)
        else
            if callback ~= nil then
                callback()
            end
        end
    else
        if callback ~= nil then
            callback()
        end
    end
end

--[[--
    发送http请求
]]


function M:httpRequestBase(request)
    if self.m_cur_request then
        return
    end
    if request == nil and #self.m_request_list > 0 then
        request = self.m_request_list[1]
        table.remove(self.m_request_list, 1)
    end
    if request == nil then
        return
    end
    self.m_cur_request = request
    local params_str = request.params_str or ""
    local method = string.upper(tostring(request.method))
    local url = request.url
    if method == GlobalConfig.GET and params_str ~= "" then
        url = url .. "&" .. params_str
    end
    if request.retry then
        if request.ingnoreState then
            url = url .. "?retry=" .. tostring(request.retry)
        else
            url = url .. "&retry=" .. tostring(request.retry)
        end
    end
    Logger.log("<color=yellow>" .. url .. "</color>")
    local time_out = __DEFAULT_TIMEOUT
    if request.ingnoreState then -- 主要是下载配置使用
        time_out = 15
    end
    if request.header ~= "0" then
        if HttpRequest.SendMsgHasHeader then
            HttpRequest:SendMsgHasHeader(url, request.tag_sign_key, params_str,method, time_out,request.header,handler(self, self.httpResponseHander))
        else
            self:closeLoading(request)
            self:cleanRequestByTag(request.tag_sign_key)
            self:handleCallback(request, 0)
        end
    else
        HttpRequest:SendMsg(url, request.tag_sign_key, params_str,method, time_out, handler(self, self.httpResponseHander))
    end
end

--[[
    统一的网络接口函数
    loadingFlag : 0        --> 不需要loading
                  1        --> 大loading
                  2        --> 小laoding

    returnFlag: 错误后是是否还回调
]]
function M:httpRequest(callback, url, method, params, tag, loadingFlag, returnFlag, delayShowLoading, ingnoreState, retry_count, pop_failed_tips_count,header)
    loadingFlag = loadingFlag or 1 
    header = header or 0
    if loadingFlag == 1 then
        static_rootControl:openView("Loading.SmallLoading",{delay_show = delayShowLoading or 2}, "net_work_small_loading")
    elseif loadingFlag == 2 then
        static_rootControl:openView("Loading.BigLoading",{delay_show = delayShowLoading}, "net_work_big_loading")
    end
    if returnFlag == nil then returnFlag = false end
    method = method or GlobalConfig.POST
    local params_str = ""
    local type_name = type(params)
    local crypto_url_value = NetUrl.getCryptoUrlValue(tag)
    if type_name == "table" or type_name == "nil" then
        params = params or {}
        if method == GlobalConfig.POST then
            params["sid"] = UserDataManager.server_data:getUserSid()
            if crypto_url_value ~= 1 then
                self.m_server_request_count = (self.m_server_request_count + 1)%1000000000000
                params["seq"] = self.m_server_request_count
            end
            params_str = Json.encode(params)
        else
            for k, v in pairs(params) do
                if type(v) == "table" then              -- 如果参数是表，那么再拆分一次 只支持一层
                    for kk,vv in pairs(v) do
                        params_str = params_str .. k .. "=" .. vv .. "&"
                    end
                else
                    params_str = params_str .. k .. "=" .. v .. "&"
                end
            end
            params_str = params_str
        end
    elseif type_name == "string" then
        params_str = params
    end

    if method == GlobalConfig.POST then
        if crypto_url_value == 1 then
            local temp_data = UserDataManager.client_data:loginEncryptToBase64String(params_str)
            params_str = temp_data
        elseif crypto_url_value == 2 then
            -- 不做加密处理
        else
            local temp_data = UserDataManager.client_data:encryptToBase64String(params_str)
            params_str = temp_data
        end
    end
    
    self.m_request_count = (self.m_request_count + 1)%1000000000000
    local tag_sign_key = tag .. "##" .. tostring(self.m_request_count)
    local request = self.m_requestMap[tag_sign_key]
    if request == nil then
    	request = {
    		callback = callback,
    		url = url,
    		method = method,
    		params = params,
            params_str = params_str,
            tag = tag,
            tag_sign_key = tag_sign_key,
    		loadingFlag = loadingFlag,
    		returnFlag = returnFlag,
    		retry_count = retry_count or __RETRY_COUNT,
            backup_retry_count = retry_count,
    		showTips = loadingFlag ~= 0,-- 当网络失败或者是异常的时候是否需要弹提示框，此处默认是没有loading的是不弹任何提示的
    	    ingnoreState = ingnoreState,
            delayShowLoading = delayShowLoading,
            pop_failed_tips_count = pop_failed_tips_count or 0,
            header = Json.encode(header) or "0"
        }
        if not self:isSameRequest(request) then
            self.m_requestMap[tag_sign_key] = request
            table.insert(self.m_request_list, request)
            self:httpRequestBase()
        else
            Logger.logWarning(tag_sign_key ,"net request is same : ")
        end
    else
        Logger.logWarning(tag_sign_key ,"net request tag exist : ")
    end
end

function M:canCloseLoading()
    local flag = true
    for k,v in ipairs(self.m_request_list) do
        if v.loadingFlag ~= 0 then
            flag = false
            break
        end
    end
    return flag
end

function M:isSameRequest(request)
    local flag = false
    if #self.m_request_list > 0 then
        for k,v in ipairs(self.m_request_list) do
            local flag = self:isSameRequestByTwoRequest(request, v)
            if flag then
                break
            end
        end
    end
    if self.m_cur_request and not flag then
        flag = self:isSameRequestByTwoRequest(request, self.m_cur_request)
    end
    return flag
end

function M:isSameRequestByTwoRequest(request, before_request)
    local flag = false
    local new_tag = request.tag
    local new_params = request.params
    local mew_type_name = type(new_params)
    if new_tag == before_request.tag then
        local type_name = type(before_request.params)
        if mew_type_name == type_name then
            if type_name == "table" then
                local diff_keys = {}
                for k1, v1 in pairs(before_request.params) do
                    if type(v1) == "table" then
                        for kk,vv in pairs(v1) do
                            if new_params[k1] and vv ~= new_params[k1][kk] then
                                table.insert(diff_keys, kk)
                            end
                        end
                    else
                        if k1 ~= "seq" then
                            if v1 ~= new_params[k1] then
                                table.insert(diff_keys, k1)
                            end
                        end
                    end
                end
                flag = #diff_keys == 0
            elseif type_name == "string" then
                if new_params == before_request.params then
                    flag = true
                end
            end
        end
    end
    return flag
end

return M
