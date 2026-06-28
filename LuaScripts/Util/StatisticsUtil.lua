------------------- StatisticsUtil
CS.StatisticsHelper.Init()
StatisticsHelper = CS.StatisticsHelper

local M = {
    -- 打点数据。
    m_point_data = {
        enterGame = {action_id = 1, name = "enterGame"},     -- 点击icon进入游戏
        --startSDKLogin = {action_id = 10, name = "startSDKLogin"},     -- 显示SDK登录界面时/开始SDK自动登录时
        --sdkLoginSuccess = {action_id = 20, name = "sdkLoginSuccess"},     -- SDK登录成功时
        --gameLoginSuccess = {action_id = 30, name = "gameLoginSuccess"},     -- 游戏登录成功时
        --startSelectServer = {action_id = 40, name = "startSelectServer"},     -- 显示选服务器界面时
        --clickEnterGameButton = {action_id = 50, name = "clickEnterGameButton"},     -- 点击创建角色/进入游戏按钮后
        --startDownloadConfig = {action_id = 60, name = "startDownloadConfig"},     -- 开始下载配置时
        --startDownloadHotUpdate = {action_id = 70, name = "startDownloadHotUpdate"},     -- 开始热更时
        --startMovie = {action_id = 80, name = "startMovie"},     -- 开始播放开场动画时
        --startNewGuide = {action_id = 90, name = "startNewGuide"},     -- 新手引导开始时
        --realNameTips = {action_id = 100, name = "realNameTips"},     --  实名制认证提示弹出框 
        startSDKLogin = {action_id = 2, name = "startSDKLogin"},     -- 显示SDK登录界面时/开始SDK自动登录时
        sdkLoginSuccess = {action_id = 3, name = "sdkLoginSuccess"},     -- SDK登录成功时
        gameLoginSuccess = {action_id = 5, name = "gameLoginSuccess"},     -- 游戏登录成功时
        startSelectServer = {action_id = 6, name = "startSelectServer"},     -- 显示选服务器界面时
        clickEnterGameButton = {action_id = 7, name = "clickEnterGameButton"},     -- 点击创建角色/进入游戏按钮后
        startDownloadConfig = {action_id = 9, name = "startDownloadConfig"},     -- 开始下载配置时
        startDownloadHotUpdate = {action_id = 8, name = "startDownloadHotUpdate"},     -- 开始热更时
        startMovie = {action_id = 10, name = "startMovie"},     -- 开始播放开场动画时
        startNewGuide = {action_id = 11, name = "startNewGuide"},     -- 新手引导开始时
        realNameTips = {action_id = 4, name = "realNameTips"},     --  实名制认证提示弹出框
    }
}

-- 发送打点数据  
function M:sendPointLog(data)
	--if GameVersionConfig and not GameVersionConfig.Debug then
		data = data or {}
        SDKUtil:appendPlatformParam(data)
        local url = NetUrl.getUrlForKey("device_action")
	    url = tostring(url) .. "&" .. NetUrl.getExtUrlParam()
	    NetWork:httpRequest(function ()
            if data.name == "startNewGuide" then
                self:finishDoPoint()
            end
        end, url, GlobalConfig.POST, data, "device_action", 0)
	--end
    local params = {iDeviceLoginType = data.action_id}
    self:logToBIByEvent("guide_flow",params)



end

-- 打点
function M:doPoint(id)
    local point_data_finish = UserDataManager.local_data:getLocalDataByKey("point_data_finish", "")
    if point_data_finish ~= "over" then 
        local point_data = self.m_point_data[id]
        if point_data then
        	self:sendPointLog(point_data)
    	end
    end
end

-- 运营活动打点  (is_share  1 分享 0其他点击)
function M:doPointActive(open_id,version,is_share)
    local share = is_share or 0
    local params = {name = "activeOnClick",action_id = 0,open_id = open_id,version = version,is_share = share}
    self:sendPointLogActive(params)
end

-- 发送打点数据  (运营活动)
function M:sendPointLogActive(data)
    data = data or {}
    SDKUtil:appendPlatformParam(data)
    local url = NetUrl.getUrlForKey("device_action")
    url = tostring(url) .. "&" .. NetUrl.getExtUrlParam()
    NetWork:httpRequest(function ()
        
    end, url, GlobalConfig.POST, data, "device_action", 0)
    local params = {open_id = data.open_id,version = data.version,is_share = data.is_share}
    self:logToBIByEvent("click_flow",params)
end

-- 标志打点完成。
function M:finishDoPoint()
    UserDataManager.local_data:setLocalDataByKey("point_data_finish", "over")
end

-- 剧情统计 sort: ""  类型 plotpop: 章节诗词,  tid: 0  章节诗词为章节 其他剧情对话为teamid, status: 0  1. 开始 2. 结束 3. 跳过
function M:sendDialoguePointLog(sort, tid, status)
    if sort == nil or tid == nil or status == nil then
        return
    end 
    local params = {sort = sort, tid = tid, status = status}
    SDKUtil:appendPlatformParam(params)
    local url = NetUrl.getUrlForKey("user_dialogue")
    url = tostring(url) .. "&" .. NetUrl.getExtUrlParam()
    NetWork:httpRequest(function () end, url, GlobalConfig.POST, params, "user_dialogue", 0)
end

function M:sendPlotPopLog(status)
    local stage_cfg = GameUtil:getBattleStageCfg()
    self:sendDialoguePointLog("plotpop", stage_cfg.chapter_id, status)
end

-----------------------下面是统计平台的接口----------------------------------------------------------------------------------------
function M:statusBiParams(params)
    params = params or {}
    if UserDataManager.user_data and UserDataManager.user_data.user_status then
        params.uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
        params.name = UserDataManager.user_data:getUserStatusDataByKey("name")
        params.level = UserDataManager.user_data:getUserStatusDataByKey("level")
    end
    if UserDataManager.client_data then
        params.user_unique_id = UserDataManager.client_data.openid --"(必填)用户OPENID号"
    else
        params.user_unique_id = ""
    end
    if UserDataManager.server_data then
        local serverData = UserDataManager.server_data:getServerData()
        if serverData then
            params.server_id = serverData.server
            --params.server_name = serverData.server_name
            params.reg_time = serverData.reg_time
        end
    else
        params.server_id = ""
        params.reg_time = ""
    end
    params.time = UserDataManager:getServerTime() --"游戏事件的时间"
    params.app_id = 6245
    Logger.log(params,"statusBiParams ======")
end

function M:onCreateRoleToBi(params)
    if not SDKUtil.is_tencent then
        params = params or {}
        self:statusBiParams(params)
        StatisticsHelper.onCreateRoleToBi(Json.encode(params))
    end
end

function M:onUserLevelChangeToBi(params)
    if not SDKUtil.is_tencent then
        params = params or {}
        self:statusBiParams(params)
        StatisticsHelper.onUserLevelChangeToBi(Json.encode(params))
    end
end

function M:onEnterGameToBi(params)
    if not SDKUtil.is_tencent then
        params = params or {}
        self:statusBiParams(params)
        StatisticsHelper.onEnterGameToBi(Json.encode(params))
    end
end

function M:payBeginToBi(params)
    if not SDKUtil.is_tencent then
        params = params or {}
        self:statusBiParams(params)
        StatisticsHelper.payBeginToBi(Json.encode(params))
    end
end

function M:paySuccessToBi(params)
    if not SDKUtil.is_tencent then
        params = params or {}
        self:statusBiParams(params)
        StatisticsHelper.paySuccessToBi(Json.encode(params))
    end
end

function M:logToBI(params)
    if not SDKUtil.is_tencent then
        params = params or {}
        self:statusBiParams(params)
        StatisticsHelper.logToBI(Json.encode(params))
    end
end

function M:logToBIByEvent(eventName, params)
    if not SDKUtil.is_tencent then
        params = params or {}
        self:statusBiParams(params)
        StatisticsHelper.logToBIByEvent(eventName, Json.encode(params))
    end

    if SDKUtil.is_oneSDK then
        SDKUtil:sendBiDataSubmit(eventName,eventName,Json.encode(params))
    end


end

return M
