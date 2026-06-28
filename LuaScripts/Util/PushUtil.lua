local M = {}

local PushSort = {
    -- 次日18点登录提示
    SixClockLogin =  1,
    -- 七日不登录
    SevenDay      =  2,
    -- 24小时后
    Hours24       = 3,
}

function M:idleRewardsPush()
    if UserDataManager.idle_info then
        local title = Language:getTextByKey("tid#pushmessege1")
        local content = Language:getTextByKey("tid#pushmessege2")
        
        local idle_start_time = UserDataManager.idle_info.idle_start_time
        local now_time = UserDataManager:getServerTime()
        -- 12小时 43200
        SDKUtil:pushAddLocalNotify(title, content, 43200 - (now_time - idle_start_time))
    end
end

function M:checkPush()
    SDKUtil:pushClearLocalNotify()
    self:idleRewardsPush()
end

-- 24小时后推送(8-22点之间，不在这个区间的，hout < 8当天推，hout>22第二天推)     
function M:hours24Push()
    local xlsxDaata = self:getPushXlsxDataBySortId(PushSort.Hours24)
    SDKUtil:PushRemoveToIdentifier(xlsxDaata.push_type)
    local title = Language:getTextByKey(xlsxDaata.title)
    local content = Language:getTextByKey(xlsxDaata.message)
    local curTimer = UserDataManager:getServerTime()
    local targetTimer = curTimer + 24 * 60 * 60
    local tarT = TimeUtil.gmTime(targetTimer)
    local tarYear = tarT.year
    local tarMonth = tarT.month
    local tarDay = tarT.day
    local tarHour = tarT.hour
    local tarMin = tarT.min
    local tarSecond = tarT.sec
    local newTargetTimer = nil
    local isTargetSection = (tarHour >= 8) and (tarHour <= 22)
    if not isTargetSection then
        local isNextDay = (tarHour > 22)
        if isNextDay then
            -- 跨2天(当晚23点登录，要在后天8点推)
            local nextDayTimer = self:getTargetTimer(2)
            -- 防止跨年跨月
            nextDayTimer = nextDayTimer + 8 * 60 * 60
            local newTarT = TimeUtil.gmTime(nextDayTimer)
            tarYear = newTarT.year
            tarMonth = newTarT.month
            tarDay = newTarT.day
            tarHour = newTarT.hour
            tarMin = 0
            tarSecond = 0
        else
            tarHour = 8
            tarMin = 0
            tarSecond = 0
        end
    end
    SDKUtil:PushOneTime(title, content, xlsxDaata.push_type, tarYear, tarMonth, tarDay, tarHour, tarMin, tarSecond)
end

-- 次日18点登录提示 推送
function M:sixClockPush()
    local xlsxDaata = self:getPushXlsxDataBySortId(PushSort.SixClockLogin)
    SDKUtil:PushRemoveToIdentifier(xlsxDaata.push_type)
    -- 超过时间就不推
    local birthTimer = self:getBirthTimer()
    local targetTimer = birthTimer + 24 * 60 * 60 
    if UserDataManager:getServerTime() >= targetTimer then
        return
    end
    -- 目标天也不推
    local curTimer = self:getCurDayTimer()
    if targetTimer == curTimer then
        return
    end
    local title = Language:getTextByKey(xlsxDaata.title)
    local content = Language:getTextByKey(xlsxDaata.message)
    local tarT = TimeUtil.gmTime(targetTimer)
    SDKUtil:PushOneTime(title, content, xlsxDaata.push_type, tarT.year, tarT.month, tarT.day, 18, 0, 0)
end

-- 获取注册当天0点
function M:getBirthTimer()
    local birthTimer = UserDataManager.reg_ts
    local birthT = TimeUtil.gmTime(birthTimer)
    local birthStartTimer = os.time({year = birthT.year, month = birthT.month, day = birthT.day, hour =00, min =00, sec = 00})
    return birthStartTimer
end

-- 七日不登录推送
function M:sevenDayPush()
    local xlsxDaata = self:getPushXlsxDataBySortId(PushSort.SevenDay)
    SDKUtil:PushRemoveToIdentifier(xlsxDaata.push_type)
    -- 超过时间就不推
    local birthTimer = self:getBirthTimer()
    local targetTimer = birthTimer + 24 * 60 * 60 * 7
    if UserDataManager:getServerTime() >= targetTimer then
        return
    end
    -- 目标天也不推
    local curTimer = self:getCurDayTimer()
    if targetTimer == curTimer then
        return
    end
    local title = Language:getTextByKey(xlsxDaata.title)
    local content = Language:getTextByKey(xlsxDaata.message)
    local tarT = TimeUtil.gmTime(targetTimer)
    -- 第七日18点推
    SDKUtil:PushOneTime(title, content, xlsxDaata.push_type, tarT.year, tarT.month, tarT.day, 18, 0, 0)
end

-- 获取几天后的0点
function M:getTargetTimer(day)
    if not day then
        return nil
    end
    local curStartTimer = self:getCurDayTimer()
    local targetTimer = curStartTimer + day * 24 * 60 * 60
    return targetTimer
end

-- 获取当天0点时间戳(s)
function M:getCurDayTimer()
    local curTimer = UserDataManager:getServerTime()
    local curT = TimeUtil.gmTime(curTimer)
    
    -- 当天0点时间
    local curStartTimer = os.time({year = curT.year, month = curT.month, day = curT.day, hour =00, min =00, sec = 00})
    return curStartTimer
end

-- 通过 推送类型拿到策划配置
function M:getPushXlsxDataBySortId(sortId)
    local push_message = ConfigManager:getCfgByName("push_message") or {}
    for _, itemData in pairs(push_message) do
        if itemData.sort == sortId then
            return itemData
        end
    end
    return nil
end

return M