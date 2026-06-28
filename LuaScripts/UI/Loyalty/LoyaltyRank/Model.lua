---@class LoyaltyRankModel: OODataBase
local M = class("LoyaltyRankModel", LikeOO.OODataBase)


function M:onCreate()
    self.open_id = self.m_params.open_id or 437
    self.m_active_data = self:getActiveData()
    self.m_version = self.m_active_data.version or 1
    self.m_activityData = UserDataManager:getActivesDataByOpenId(self.m_openId)
    self:getData("red_envelope_personal_rank", {start = 1, stop = 10})
end


function M:onEnter()
    --Logger.logError(self.m_data,"data~~~~~~~~~~~~~~~~")
    self.is_persion = 1 --1：个人榜，2：帮会榜
    self.m_selectTabIndex = 1 --1：个人榜，2：帮会榜
    self.roleRankData = {}
    self.teamRankData = {}
    self:refreshRankData(self.m_data,self.is_persion)
    self.personData = self.m_data
end

function M:setSelectIndex(index)
    self.m_selectTabIndex = index
end

function M:refreshRankData(m_data,is_persion)
    local personData = self.personData or {}
    local guildData = self.guildData or {}
    if is_persion == 1 then
        personData = m_data
    else
        guildData = m_data
    end
    if personData.ranks and is_persion == 1 then
        for i,v in pairs(personData.ranks) do
            table.insert(self.roleRankData,v)
        end
    end
    --self.roleRankData = personData.ranks or {}
    self.roleRankCount = personData.count or 0
    if self.roleRankCount > 0 and table.nums(self.roleRankData) > 0 then
        table.sort(self.roleRankData, function(itemData1, itemData2) return itemData1.rank < itemData2.rank end)
    end
    if guildData.ranks and is_persion == 2 then
        for i,v in pairs(guildData.ranks) do
            table.insert(self.teamRankData,v)
        end
    end
    --self.teamRankData = guildData.ranks or {}
    self.teamRankCount = guildData.count or 0
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

function M:getLoadIndex(index)
    local max_rank_count =index == 1 and self.roleRankCount or self.teamRankCount
    local cur_rank_nums = index == 1  and table.nums(self.roleRankData) or table.nums(self.teamRankData)
    local start_pos, end_pos = 0, 0
    if cur_rank_nums + 10 <= max_rank_count then
        start_pos = cur_rank_nums + 1
        end_pos = cur_rank_nums + 10
    elseif max_rank_count - cur_rank_nums > 0 then
        start_pos = cur_rank_nums + 1
        end_pos = max_rank_count
    end
    return start_pos, end_pos
end

--获取活动数据
function M:getActiveData()
    local active_tab = ConfigManager:getCfgByName("active")
    local activityData = UserDataManager:getActivesDataByOpenId(self.open_id)
    return active_tab[activityData.id]
end

return M
