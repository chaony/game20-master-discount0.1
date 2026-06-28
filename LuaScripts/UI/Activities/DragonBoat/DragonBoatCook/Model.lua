---@class DeliciousFeastCookModel: OODataBase
local M = class("DragonBoatCookModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self:initData()
end

function M:initData()
    self.m_version_cfg = {}
    self.m_versionId = self.m_params.versionId
    self.m_curSelIndex = 0
    local cfg = ConfigManager:getCfgByName("meituan_cook")
    if cfg then
        self.m_version_cfg = cfg[self.m_versionId]
    end
    
    --表格数据只取一次，道具数量以getMaterialData()实时拿的为准
    self.m_itemData = {}
    for k, v in ipairs(self.m_version_cfg) do
        if #v.target[1] == 3 then   --目标只取第一个
            local target_data = RewardUtil:getProcessRewardData(v.target[1])
            table.insert(self.m_itemData, { id = k, target_data = target_data, materials_data = v.material })
        end
    end
end

function M:getCurSelectData()
    return self.m_itemData[self.m_curSelIndex]
end

function M:getTargetData()
    local targetData = {}
    for k, v in ipairs(self.m_itemData) do
        table.insert(targetData, v.target_data)
    end
    return targetData
end

--function M:getMaterialData()
--    if self.m_materialData == nil then
--        for k, v in ipairs(self.m_itemData) do
--            table.insert(self.m_materialData, v.material)
--        end
--    end
--    return self.m_materialData
--end

function M:getTargetMaxNums()
    local maxNums = {}
    local maxNum = 99999999
    for k, v in ipairs(self.m_itemData) do
        maxNum = 99999999
        for i = 1, #v.materials_data do
            if #v.materials_data[i] == 3 and v.materials_data[i][1] == RewardUtil.REWARD_TYPE_KEYS.ITEM and v.materials_data[i][3] > 0 then
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
        table.insert(maxNums, maxNum)
    end
    return maxNums
end

function M:checkIsOfficial()
    return self.m_params.isOfficial
end

function M:getCurIndex()
    return self.m_curSelIndex
end

function M:setCurIndex(index)
    if index ~= self.m_curSelIndex then
        self.m_curSelIndex = index
    end
    
end

function M:getOpenId()
    return self.m_params.openId
end

function M:getVersion()
    return self.m_versionId
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

return M