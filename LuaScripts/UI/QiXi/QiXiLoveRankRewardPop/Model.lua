---@class DeliciousFeastRankRewardPopModel: OODataBase
local M = class("QiXiLoveRankRewardPopPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_versionId = self.m_params.version or 1
    self:setRoleRankData()
    self:getData()
end

local __TAB_BTN_NODE = {
    {btn_key = "role_bank_toggle",btn_text = "role_toggle_text", text_key = "qi_xi_109", open = true}, -- 魅力榜
    {btn_key = "team_bank_toggle",btn_text = "team_toggle_text", text_key = "qi_xi_110", open = true}, -- 情谊榜
}

function M:onEnter()

end

function M:setTeamRankData()
    self.m_rankAwards_data = {}
    local configXlsxData = ConfigManager:getCfgByName("flower_guild_reward")
    local cfgData = configXlsxData[self.m_versionId]
    self.m_maxIndex = #cfgData
    for k, v in pairs(cfgData) do
        table.insert(self.m_rankAwards_data, {
            rank = v.rank,
            award = v.rank_rewards,
        })
    end
end

function M:setRoleRankData()
    self.m_rankAwards_data = {}
    local configXlsxData = ConfigManager:getCfgByName("flower_rank_reward")
    local cfgData = configXlsxData[self.m_versionId]
    self.m_maxIndex = #cfgData
    for k, v in pairs(cfgData) do
        table.insert(self.m_rankAwards_data, {
            rank = v.rank,
            award = v.rank_rewards,
        })
    end
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
