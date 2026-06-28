---@class HalfAnniversaryTotalTaskModel: OODataBase
local M = class("HalfAnniversaryTotalTaskModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_openId = self.m_params.openId
    self:getData("half_year_quest_index")
end

function M:onEnter()
    self:initActivityData()
end

function M:initActivityData()
    self.m_version = self.m_data.version
    self.m_score = self.m_data.score
    self.m_self_score = self.m_data.self_score
    self.m_quests_data = self.m_data.quests
    self.m_activityData = UserDataManager:getActivesDataByOpenId(self.m_openId)
    self.m_max_award_num = 5    --UI只有五个
    self.maxTaskDay = 1
    -- 领取过得玄铁目标宝箱
    if self.m_data.score_done then
        self:setScoreDone(self.m_data.score_done)
    end
    self:setAllTaskData()   -- self.m_taskData
    self:setAllAwardsData() -- self.m_allAwardsData 
    self:setAwardState()    -- self.m_curAwardIndex
end

function M:refreshActivityData(response)
    self.m_score = response.score
    self.m_self_score = response.self_score
    self.m_quests_data = response.quests
end

function M:setScoreDone(score_done)
    self.m_score_done = {}
    for i = 1, #score_done do
        local index = score_done[i]
        self.m_score_done[index] = index
    end
end

function M:getMaxTaskDay()
    return self.maxTaskDay
end

function M:setAllTaskData()
    local questData = ConfigManager:getCfgByName("half_year_quest")
    local versionQuestData = questData[self.m_version] or {}
    self.m_taskData = {
        dayTaskData = {},
        allTaskData = {},
    }
    for id, itemData in pairs(versionQuestData) do
        if (itemData.sort == 1) then
            local curServerData = self.m_quests_data[tostring(id)] or {}
            if (itemData.type == 2) then
                -- 每期任务 
                table.insert(self.m_taskData.allTaskData, {
                    xlsxData = itemData,
                    serverData = curServerData,
                    id = id,
                })
            elseif (itemData.type == 1) then
                --每日任务 (key是天数)
                if(itemData.day > self.maxTaskDay) then
                    --记最大天数
                    self.maxTaskDay = itemData.day
                end
                self.m_taskData.dayTaskData[itemData.day] = {
                    xlsxData = itemData,
                    serverData = curServerData,
                    id = id,
                }
            end
        end
    end
    table.sort(self.m_taskData.allTaskData, function(itemData1, itemData2)
        local gotId1 = self:getSortIndex(itemData1.serverData.status)
        local gotId2 = self:getSortIndex(itemData2.serverData.status)
        if gotId1 ~= gotId2 then
            return gotId1 < gotId2
        else
            return itemData1.id < itemData2.id
        end
    end)
    -- self.m_taskData = tempData
end

function M:getSortIndex(status)
    --0: 未完成,1：已完成，2：已领取
    -- 返回的顺序是1已完成，2未完成，3已领取
    if status == 0 then
        return 2
    elseif status == 1 then
        return 1
    elseif status == 2 then
        return 3
    end
    return 4
end

-- 完成任务修改
function M:amendTaskData(id)
    for _, itemData in pairs(self.m_taskData.allTaskData) do
        if itemData.id == id then
            itemData.serverData.status = 2
            break
        end
    end
end

function M:getActivityOpenDay()
    if self.m_activityData then
        local openDayCount = GameUtil:getActityOpenDayCount(self.m_activityData.start_ts)
        return math.floor(openDayCount)
    end
    return 0
end

function M:setAllAwardsData()
    local rewardData = ConfigManager:getCfgByName("half_year_reward")
    local versionRewardData = rewardData[self.m_version] or {}
    self.m_allAwardsData = {}
    for id, itemData in ipairs(versionRewardData) do
        local isReceived = false
        if self.m_score_done and self.m_score_done[id] then
            isReceived = true
        end
        self.m_allAwardsData[id] = {
            xlsxData = itemData,
            id = id,
            isReceived = isReceived
        }
    end
end

function M:updateAwardState(score_done)
    self:setScoreDone(score_done)
    for id, itemData in ipairs(self.m_allAwardsData) do
        local isReceived = false
        if self.m_score_done and self.m_score_done[id] then
            isReceived = true
        end
        itemData.isReceived = isReceived
    end
end


function M:setAwardState()
    self.m_curAwardIndex = 1
    for id, itemData in ipairs(self.m_allAwardsData) do
        if self.m_score >= itemData.xlsxData.score then
            self.m_curAwardIndex = id + 1
        end
    end
    self.m_curAwardIndex = self.m_curAwardIndex > self.m_max_award_num and self.m_max_award_num or self.m_curAwardIndex
end




function M:checkActivityOpen()
    local openId = self.m_openId
    self.m_activityData = UserDataManager:getActivesDataByOpenId(openId)
    if not self.m_activityData then
        return false
    end
    if self.m_activityData.open_status == 2 then
        return false
    end
    --直接用展示时间
    local curTime = UserDataManager:getServerTime()
    local endTime = self.m_activityData.show_start_ts or 0
    return curTime <= endTime
end


return M