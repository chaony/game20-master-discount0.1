---@class DeliciousFeastRankRewardPopModel: OODataBase
local M = class("WindAndCloudMoonRankRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_versionId = self.m_params.version or 1
    self.m_open_id = self.m_params.open_id or 406
    self:setRoleRankData()
    self:getData()
end

function M:onEnter()

end

function M:setRoleRankData()
    self.m_rankAwards_data = {}
    local configXlsxData = ConfigManager:getCfgByName("diamond_rebate_rank")
    local cfgData = configXlsxData[self.m_open_id][self.m_versionId]
    for k, v in pairs(cfgData) do
        table.insert(self.m_rankAwards_data, {
            rank = v.rank,
            award = v.rank_reward,
        })
    end
    table.sort(self.m_rankAwards_data, function(data1, data2)
        return data1.rank[1] < data2.rank[1]
    end)
    self.m_maxIndex = #self.m_rankAwards_data
end


function M:setSelectIndex(index)
    self.m_selectTabIndex = index
end

function M:getDataCountList()
    return self.m_maxIndex
end

return M
