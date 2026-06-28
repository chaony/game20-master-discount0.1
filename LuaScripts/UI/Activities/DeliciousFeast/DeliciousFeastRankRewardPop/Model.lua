---@class DeliciousFeastRankRewardPopModel: OODataBase
local M = class("DeliciousFeastRankRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_versionId = self.m_params.version or 1
    self:setRankData()
    self:getData()
end

function M:onEnter()

end

function M:setRankData()
    self.m_rankAwards_data = {}
    local configXlsxData = ConfigManager:getCfgByName("meituan_rank")
    local cfgData = configXlsxData[self.m_versionId]
    self.m_maxIndex = #cfgData
    for k, v in pairs(cfgData) do
        table.insert(self.m_rankAwards_data, {
            rank = v.rank,
            award = v.rank_reward,
        })
    end
end

function M:getDataCountList()
    return self.m_maxIndex
end

return M
