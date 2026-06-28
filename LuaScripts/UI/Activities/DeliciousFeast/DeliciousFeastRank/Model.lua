---@class DeliciousFeastRankModel: OODataBase
local M = class("DeliciousFeastRankModel", LikeOO.OODataBase)


function M:onCreate()
    self.m_version = self.m_params.versionId
    self.m_openId = self.m_params.openId
    self.m_activityData = UserDataManager:getActivesDataByOpenId(self.m_openId)
    self:getData("feast_rank", {start = 1, stop = 10})
end


function M:onEnter()
    self:initData()
end

function M:initData()
    self.m_roleRankData = self.m_data.ranks
    self.m_roleRankCount = self.m_data.count
    if self.m_roleRankCount > 1 and table.nums(self.m_roleRankData) > 1 then
        table.sort(self.m_roleRankData, function(itemData1, itemData2) return itemData1.rank < itemData2.rank end)
    end

    self.m_myRankInfoData = {
        rank = self.m_data.rank,
        score = self.m_data.score,
    }
end

function M:getMyRankInfo()
    return self.m_myRankInfoData
end

function M:getRankCount()
    return self.m_roleRankCount
end

function M:getTopThreeListData()
    local retList = {}
    for index = 1, 3 do
        retList[index] = self.m_roleRankData[index]
    end
    return retList
end

function M:getRankListData()
    local retList = {}
    for index = 3, self.m_roleRankCount do
        retList[index - 2] = self.m_roleRankData[index]
    end
    return retList
end

function M:getXlsxActivityByOpenId(openId, isRechargeActivity)
    local xlsxName = isRechargeActivity and "active_recharge" or "active"
    local active = ConfigManager:getCfgByName(xlsxName)
    for _,itemData in pairs(active) do
        if (itemData.version == self.m_version) and (openId == itemData.open_id) then
            return itemData
        end
    end
    return nil
end

function M:getActivityData()
    return self.m_activityData
end

return M
