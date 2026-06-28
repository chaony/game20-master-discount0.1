---@class DeliciousFeastRankRewardPopModel: OODataBase
local M = class("LoyaltyRankRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_versionId = self.m_params.version or 1
    self:setRoleRankData()
    self:getData()
end

local __TAB_BTN_NODE = {
    {btn_key = "role_bank_toggle",btn_text = "role_toggle_text", text_key = "flower_text_0009", open = true}, -- 魅力榜
    {btn_key = "team_bank_toggle",btn_text = "team_toggle_text", text_key = "flower_text_0010", open = true}, -- 情谊榜
}

function M:onEnter()

end

function M:setTeamRankData()
    self.m_rankAwards_data = {}
    local configXlsxData = ConfigManager:getCfgByName("red_envelope_rank_guild")
    local cfgData = configXlsxData[self.m_versionId]
    self.m_maxIndex = #cfgData
    for k, v in pairs(cfgData) do
        table.insert(self.m_rankAwards_data, {
            rank = v.rank,
            award = v.reward,
            id = v.id
        })
    end
    table.sort(self.m_rankAwards_data,function(a, b)  
        return a.id < b.id
    end)
end

function M:setRoleRankData()
    self.m_rankAwards_data = {}
    local configXlsxData = ConfigManager:getCfgByName("red_envelope_rank_personal")
    local cfgData = configXlsxData[self.m_versionId]
    self.m_maxIndex = #cfgData
    for k, v in pairs(cfgData) do
        table.insert(self.m_rankAwards_data, {
            rank = v.rank,
            award = v.reward,
            id = v.id
        })
    end
    table.sort(self.m_rankAwards_data,function(a, b)
        return a.id < b.id
    end)
end

function M:getTabBtnNode()
    return __TAB_BTN_NODE
end

function M:setSelectIndex(index)
    self.m_selectTabIndex = index
end

function M:getDataCountList()
    return self.m_maxIndex
end

return M
