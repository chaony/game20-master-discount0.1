---@class HalfAnniversaryLotteryPlayerPopModel: OODataBase
local M = class("HalfAnniversaryLotteryPlayerPopModel", LikeOO.OODataBase)

local TAB_BTN_NODE = {
    { open_id = 322, isRechargeAct = false, lua_name = "Activities.DeliciousFeast.DeliciousFeastBless" }, -- 食神祝福 任务
    { open_id = 323, isRechargeAct = false, lua_name = "Activities.DeliciousFeast.DeliciousFeastCook" }, -- 美味尝鲜 制作
    { open_id = 324, isRechargeAct = true, lua_name = "Activities.DeliciousFeast.DeliciousFeastGiftBag" }, -- 美味集市 礼包
    { open_id = 325, isRechargeAct = false, lua_name = "Activities.DeliciousFeast.DeliciousFeastExchange" }, -- 美味兑换
    { open_id = 326, isRechargeAct = false, lua_name = "Activities.DeliciousFeast.DeliciousFeastRank" }, -- 厨神争霸 排行榜
}
function M:onCreate()
    M.super.onCreate(self)
    self:getData("")
end

function M:onEnter()
    self:initData()

end
function M:initData()
    self.m_mainOpenId = self.m_params.open_id or 321
    self.m_versionId = self.m_data.version
    self.m_isOfficial = false
end

-- 活动是否开启中
function M:isOpenActiveByIndex(index, isShowTime)
    local configData = TAB_BTN_NODE[index]
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
    if (not isShowTime and activityData.open_status == 2) then
        return false
    end
    --直接展示时间
    local curTime = UserDataManager:getServerTime()
    local endTime = activityData.end_ts or 0
    return curTime <= endTime

end

function M:getTabConfigByIndex(index)
    return TAB_BTN_NODE[index]
end

function M:getVersion()
    return self.m_versionId
end

function M:checkIsOfficial()
    return self.m_isOfficial
end

function M:getActivityData()
    return UserDataManager:getActivesDataByOpenId(self.m_mainOpenId)
end

function M:updateTaskData(data)
    if data.refresh then
        self.m_data.quests = data.quests or {}
    else
        table.merge(self.m_data.quests, data.quests)
    end
end

function M:checkTaskRed()
    self.m_taskRedPoint = false
    if not self:isOpenActiveByIndex(1, false) then
        return
    end
    local quests = self.m_data.quests or {}
    for k, v in pairs(quests) do
        if v.status == 1 then
            self.m_taskRedPoint = true
            break
        end
    end
end

function M:getTaskRedPoint()
    return self.m_taskRedPoint
end

function M:getCookRedPoint()
    return self.m_cookRedPoint
end


return M