------------------- NetWork

local M = {
    m_requestMap = {},
    m_request_count = 0,
}

local HttpRequest = CS.wt.framework.HttpRequest.Inst
local __RETRY_COUNT = 2
local __RETRY_TIME = 2     -- 多长时间后重试, 单位秒
local __DEFAULT_TIMEOUT = 5

function M:handleStatusError(data, request)

end

function M:handleNetWorkFailed(net_data, request)
    local function doRetry()
        request.retry = (request.retry or 0) + 1        -- 记录重试次数
        self:httpRequestBase(request)
    end
    if request.retry_count > 0 then   -- 有重试次数等待响应
        request.retry_count = request.retry_count - 1
        EventDispatcher:registerTimeEvent("tssTryAgain", doRetry, __RETRY_TIME, __RETRY_TIME)
    else
        self:cleanRequestByTag(request.tag_sign_key)
        if type(request.callback) == "function" then
            --Logger.log("222222222")
            request.callback()
        end
    end
end

function M:cleanRequestByTag(tag)
    self.m_requestMap[tag] = nil
end

-- 网络回调处理
function M:httpResponseHander(success, net_data, tag_sign_key)
    local request = self.m_requestMap[tag_sign_key]
    if success then -- 成功
        local tag = request.tag
        self:cleanRequestByTag(tag_sign_key)
        if type(request.callback) == "function" then
            --Logger.log("111111111111")
            request.callback(net_data, tag)
        else
            Logger.log("not callback func => " .. tostring(tag))
        end
    else -- 网络请求失败
        self:handleNetWorkFailed(net_data, request)
    end
end

--[[--
    发送http请求
]]

function M:httpRequestBase(request)
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
    if request.ingnoreState then
        time_out = 15
    end
    HttpRequest:SendMsg2(url, request.tag_sign_key, request.betyData,method, time_out, handler(self, self.httpResponseHander))
end

--[[
    统一的网络接口函数
    returnFlag: 错误后是是否还回调
]]
function M:httpRequest(callback, url, method, betyData, tag, returnFlag, ingnoreState)
    if returnFlag == nil then returnFlag = false end
    method = method or GlobalConfig.POST
    
    self.m_request_count = (self.m_request_count + 1)%100000000
    local tag_sign_key = tag .. "##" .. tostring(self.m_request_count)
    local request = self.m_requestMap[tag_sign_key]
    if request == nil then
    	request = {
    		callback = callback,
    		url = url,
    		method = method,
            betyData = betyData,
            tag = tag,
            tag_sign_key = tag_sign_key,
    		returnFlag = returnFlag,
    		retry_count = __RETRY_COUNT,
    	    ingnoreState = ingnoreState
        }
        self.m_requestMap[tag_sign_key] = request
    else
        Logger.logWarning(tag_sign_key ,"net request tag exist : ")
    end
    self:httpRequestBase(request)
end

return M
