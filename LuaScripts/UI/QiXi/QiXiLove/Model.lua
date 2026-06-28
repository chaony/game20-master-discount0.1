---@class DeliciousFeastRankModel: OODataBase
local M = class("QiXiLoveModel", LikeOO.OODataBase)


function M:onCreate()
    self.open_id = self.m_params.open_id or 291
    self.m_active_data = self:getActiveData()
    self.m_version = self.m_active_data.version or 1
    self.m_activityData = UserDataManager:getActivesDataByOpenId(self.m_openId)
    self:getData("flower_index", {vsn = self.m_version,start = 1, stop = 10})
end


function M:onEnter()
    self:refreshRankData(self.m_data)
end

function M:setSelectIndex(index)
    self.m_selectTabIndex = index
end

function M:refreshRankData(m_data)
    local personData = m_data.person
    local guildData = m_data.give_rank_data
    self.roleRankData = personData.ranks
    self.roleRankCount = personData.count
    if self.roleRankCount > 0 and table.nums(self.roleRankData) > 0 then
        table.sort(self.roleRankData, function(itemData1, itemData2) return itemData1.rank < itemData2.rank end)
    end
    self.teamRankData = guildData.ranks
    self.teamRankCount = guildData.count
    if self.teamRankCount > 0 and table.nums(self.teamRankData) > 0 then
        table.sort(self.teamRankData, function(itemData1, itemData2) return itemData1.rank < itemData2.rank end)
    end

    self.myInfoData = {
        rank = personData.rank,
        score = personData.score,
    }
    self.myTeamData = {
        rank = guildData.rank,
        score = guildData.score,
        flag = guildData.flag,
    }
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

--获取活动数据
function M:getActiveData()
    local active_tab = ConfigManager:getCfgByName("active")
    local activityData = UserDataManager:getActivesDataByOpenId(self.open_id)
    return active_tab[activityData.id]
end

return M
