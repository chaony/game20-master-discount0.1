---@class DeliciousFeastBlessModel: OODataBase
local M = class("DeliciousFeastBlessModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("feast_main_index")
end

function M:onEnter()
    self:initData()
end

function M:initData()
    self.m_curTabIndex = 1
    self.m_version = self.m_params.versionId
    self:setCurDayIndex(self.m_data.cur_day)
    self:updateQuestsData(self.m_data.quests, true)
    self:updateBlessNum(self.m_data.pray)
    local common_cfg = ConfigManager:getCfgByName("common")
    if common_cfg and next(common_cfg) then
        self.m_blessNeedNum = common_cfg[728].value or 0
    end
end

function M:updateQuestsData(data ,isRefresh)
    if isRefresh then
        self.m_data.quests = data or {}
    else 
        table.merge(self.m_data.quests, data)
    end
    
    self.m_dailyQuestData = {}
    self.m_totalQuestData = {}
    self.m_isHaveDailyRedPoint = false
    self.m_isHaveTotalRedPoint = false
    self:refreshQuestData()
end

function M:updateBlessNum(num)
    self.m_blessNum = num
end

function M:refreshQuestData()
    local quests_cfg = ConfigManager:getCfgByName("meituan_quest")
    local version_quests_config = quests_cfg[self.m_version] or {}
    local quests = self.m_data.quests or {}
    for k, v in pairs(quests) do
        local key = tonumber(k)
        local cfg = version_quests_config[key]
        if cfg then
            local value = v.value or 0
            local status = v.status or 0
            local target_value = cfg.target_value
            if status == 2 then
                status = -1     --领取奖励状态
            else
                --if value >= target_value and status == 1 then --以服务器状态为准
                if status == 1 then
                    -- 完成可领取
                    status = 2
                end
            end
            local lock_flag, lock_text = ConfigManager:getQuestLockFlag(cfg.stage_id)
            if lock_flag then
                status = -0.5
            else
                if status == 2 then
                    if cfg.sort == 1 then
                        self.m_isHaveDailyRedPoint = true
                        elseif cfg.sort == 2 then
                        self.m_isHaveTotalRedPoint = true
                    end
                end
            end
            local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(cfg, value)
            if cfg.sort == 1 then
                --日常
                table.insert(self.m_dailyQuestData, { id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress, lock_flag = lock_flag, lock_text = lock_text })
            elseif cfg.sort == 2 then
                --总计
                table.insert(self.m_totalQuestData, { id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress, lock_flag = lock_flag, lock_text = lock_text })
            end
           
        end
    end
    GameUtil:taskDataSort(self.m_dailyQuestData)
    GameUtil:taskDataSort(self.m_totalQuestData)
end

function M:getCurTabIndex()
    return self.m_curTabIndex
end

function M:setCurTabIndex(index)
    self.m_curTabIndex = index
end

function M:getBlessNum()
    return self.m_blessNum
end

function M:checkCanBless()
    return self.m_blessNum >= self.m_blessNeedNum
end

function M:getNeedBless()
    return self.m_blessNeedNum
end

function M:getTaskData()
    if self.m_curTabIndex == 1 then
        return self.m_dailyQuestData
    else
        return self.m_totalQuestData
    end
end

function M:getRedPointFlag(index)
    if index == 1 then
        return self.m_isHaveDailyRedPoint
    elseif index == 2 then
        return self.m_isHaveTotalRedPoint
    end
    return false
end

function M:getCurVersion()
    return self.m_version
end

function M:checkIsOfficial()
    return self.m_params.isOfficial
end

function M:checkActivityOpen()
    local openId = self.m_params.openId
    local activityData = nil
    activityData = UserDataManager:getActivesDataByOpenId(openId)
    if not activityData then
        return false
    end
    if activityData.open_status == 2 then
        return false
    end
    --直接用展示时间
    local curTime = UserDataManager:getServerTime()
    local endTime = activityData.show_start_ts or 0
    return curTime <= endTime
end

function M:getSpineName()
    return self.m_params.spineName
end

function M:getCurDayIndex()
    return self.m_curDayIndex
end

function M:setCurDayIndex(dayIndex)
    self.m_curDayIndex = dayIndex
end
return M