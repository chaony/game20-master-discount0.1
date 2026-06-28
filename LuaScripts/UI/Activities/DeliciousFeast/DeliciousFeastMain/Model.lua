---@class DeliciousFeastMainModel: OODataBase
local M = class("DeliciousFeastMainModel", LikeOO.OODataBase)

local TAB_BTN_NODE = {
    { open_id = 322, isRechargeAct = false, lua_name = "Activities.DeliciousFeast.DeliciousFeastBless" }, -- 食神祝福 任务
    { open_id = 323, isRechargeAct = false, lua_name = "Activities.DeliciousFeast.DeliciousFeastCook" }, -- 美味尝鲜 制作
    { open_id = 324, isRechargeAct = true, lua_name = "Activities.DeliciousFeast.DeliciousFeastGiftBag" }, -- 美味集市 礼包
    { open_id = 325, isRechargeAct = false, lua_name = "Activities.DeliciousFeast.DeliciousFeastExchange" }, -- 美味兑换
    { open_id = 326, isRechargeAct = false, lua_name = "Activities.DeliciousFeast.DeliciousFeastRank" }, -- 厨神争霸 排行榜
}
function M:onCreate()
    M.super.onCreate(self)
    self:getData("feast_main_index")
end

function M:onEnter()
    self:initData()

end
function M:initData()
    self.m_mainOpenId = self.m_params.open_id or 321
    self.m_versionId = self.m_data.version
    self.m_isOfficial = false
    self:checkTaskRed()
    self:checkCookRed()
    if SDKUtil.is_gmsdk then
        local bundleId = SDKUtil.sdk_params.applicationId or ""
        if bundleId == "com.hermes.wl" then
            self.m_isOfficial = true
        end
    end
    --self.m_isOfficial = true
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
    if(not isShowTime and activityData.open_status == 2) then
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

function M:checkCookRed()
    self.m_cookRedPoint = false
    if not self:isOpenActiveByIndex(2, false) then
        return
    end
    if self.m_cookData == nil then
        local cfg = ConfigManager:getCfgByName("meituan_cook")
        if cfg then
            self.m_version_cfg = cfg[self.m_versionId]
        end
        self.m_cookData = {}
        for k, v in ipairs(self.m_version_cfg) do
            table.insert(self.m_cookData, { materials_data = v.material })
        end
    end

    local maxNum = 9999999
    for k, v in ipairs(self.m_cookData) do
        for i = 1, #v.materials_data do
            maxNum = 10
            if #v.materials_data[i] == 3 and v.materials_data[i][1] == RewardUtil.REWARD_TYPE_KEYS.ITEM then
                local item_data = UserDataManager.item_data:getItemDataById(v.materials_data[i][2]) or {}
                local num = math.floor(item_data.num / v.materials_data[i][3])
                if num == 0 then
                    maxNum = 0
                    break
                else
                    maxNum = math.min(maxNum, num)
                end

            end
        end
        if maxNum > 0 then
            self.m_cookRedPoint = true
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

function M:getSpineName()
    local spine = { meituan = "MeiTuan_SkeletonData", xian = "hero_0101_yongzhuang_SkeletonData"}
    return spine
end

return M