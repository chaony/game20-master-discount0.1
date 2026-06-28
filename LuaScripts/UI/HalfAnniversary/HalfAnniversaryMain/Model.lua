---@class HalfAnniversaryMainModel: OODataBase
local M = class("HalfAnniversaryMainModel", LikeOO.OODataBase)

local TAB_BTN_NODE = {
    { open_id = 333, isRechargeAct = false, isHaveShowTime = false, lua_name = "HalfAnniversary.HalfAnniversaryGrouping" }, -- 蓬莱集市 拼队
    { open_id = 334, isRechargeAct = false, isHaveShowTime = false, lua_name = "HalfAnniversary.HalfAnniversarySign" }, -- 日历 签到
    { open_id = 328, isRechargeAct = false, isHaveShowTime = false, lua_name = "HalfAnniversary.HalfAnniversaryTotalTask" }, -- 装扮 全服任务
    { open_id = 331, isRechargeAct = false, isHaveShowTime = true, lua_name = "HalfAnniversary.HalfAnniversaryLottery" }, -- 锦鲤 抽奖
    { open_id = 329, isRechargeAct = true, isHaveShowTime = false, lua_name = "HalfAnniversary.HalfAnniversaryGiftBag" }, -- 庆典坊市  礼包
    { open_id = 327, isRechargeAct = false, isHaveShowTime = false, lua_name = "" }, -- 神兽来袭
    { open_id = 330, isRechargeAct = false, isHaveShowTime = false, lua_name = "HalfAnniversary.HalfAnniversarySecret" }, -- 神兽秘境
}
function M:onCreate()
    M.super.onCreate(self)
    self:getData("")
end

function M:onEnter()
    self:initData()

end
function M:initData()
    self.m_open_id = self.m_params.open_id or 332
    local activeXlsxData = UserDataManager:getActivesDataByOpenId(self.m_open_id)
    self.m_version = activeXlsxData.version
    self:initActiveConfig()
    --self.m_version = self.m_data.version
end

--检测所有活动状态
function M:checkActivityStates()
    self.m_activityStates = {}
    local isOpen
    for k, v in pairs(TAB_BTN_NODE) do
        isOpen = self:isOpenActiveByIndex(k)
        self.m_activityStates[v.open_id] = isOpen
    end
    return self.m_activityStates
end

-- 活动是否开启中
function M:isOpenActiveByIndex(index)
    local configData = TAB_BTN_NODE[index]
    if index == 4 then
        local a = 1
    end
    local isHaveShowTime = configData.isHaveShowTime
    local openId = configData.open_id
    local activityData = nil
    if configData.isRechargeAct then
        activityData = UserDataManager:getActivesRechargeDataByOpenId(openId)
    else
        activityData = UserDataManager:getActivesDataByOpenId(openId)
    end
    if not activityData then
        return false
    end
    if (not isHaveShowTime and activityData.open_status == 2) then
        return false
    end
    --直接展示时间
    local curTime = UserDataManager:getServerTime()
    local endTime = activityData.end_ts or 0
    return curTime <= endTime
end

function M:initActiveConfig()
    self.m_activeTimeConfig = {}
    for k, v in ipairs(TAB_BTN_NODE) do
        local tableActivityCfg = nil
        local configData = TAB_BTN_NODE[k]
        local openId = configData.open_id
        local tableActivityCfgs = {}
        tableActivityCfg = self:getActivityConfigsByOpenId(openId, configData.isRechargeAct)
        if tableActivityCfg then
            for vsn, cfg in pairs(tableActivityCfg) do
                local start_time = 0 
                local end_time = 0
                local show_time = 0
                start_time = GameUtil:stringToTimesTamp(cfg.start_time) or 0
                end_time = GameUtil:stringToTimesTamp(cfg.end_time) or 0
                if cfg.show_time and cfg.show_time ~= "" then
                    show_time = GameUtil:stringToTimesTamp(cfg.show_time)
                end
                tableActivityCfgs[vsn] = {start_time = start_time, end_time = end_time, show_time = show_time }
            end
            
        end
        table.insert(self.m_activeTimeConfig, tableActivityCfgs)
    end
    
end

-- 活动开启关闭状态
function M:getOpenStateActiveByIndex(index)
    local configData = TAB_BTN_NODE[index]
    local isHaveShowTime = configData.isHaveShowTime
    local activeTimeCfgs = self.m_activeTimeConfig[index]
    local state = 3
    local start_time = 0
    for k,activeTimeCfg in ipairs(activeTimeCfgs) do
        if activeTimeCfg.start_time == 0 then
            state = 3 --关闭
        else
            local curTime = UserDataManager:getServerTime()
            if curTime < activeTimeCfg.start_time then
                --以第一个版本号为开启时间
                state = 2
                start_time = activeTimeCfg.start_time--未开启
                return state, start_time
            elseif curTime < activeTimeCfg.end_time or (isHaveShowTime and curTime < activeTimeCfg.show_time) then
                return 1 --开放状态
            else
                state = 3 --关闭
            end
        end
    end
    return state, start_time
    
end

function M:getActivityConfigsByOpenId(openId, isRechargeActivity)
    local xlsxName = isRechargeActivity and "active_recharge" or "active"
    local configs = {}
    local active = ConfigManager:getCfgByName(xlsxName)
    for _, itemData in pairs(active) do
        if itemData.open_id == 327 then
            local x = 1
        end
        if (openId == itemData.open_id) then
            configs[itemData.version] = itemData
        end
    end
    return configs
end

function M:getTabConfigByIndex(index)
    return TAB_BTN_NODE[index]
end

function M:getVersion()
    return self.m_version
end

return M