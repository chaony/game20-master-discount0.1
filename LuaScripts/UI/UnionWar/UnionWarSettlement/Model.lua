local M = class("UnionWarSettlementModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)
    self:getData()    
end

function M:onEnter()
    self.m_round_report = self.m_params.round_report or {}
    self.m_last_report = self.m_params.last_report or {}
end

function M:getGuildInfo(idx)
    local vs = self.m_round_report.vs or {}
    local gid = vs[idx] or ""
    local guild_info = self.m_round_report.guild_info or {}
    local guild_info_item = guild_info[tostring(gid)] or {}
    local guild_flag_cfg = ConfigManager:getCfgByName("guild_flag")
    local guild_flag_cfg_item = guild_flag_cfg[guild_info_item.flag] or {}
    return guild_info_item, guild_flag_cfg_item.icon
end

return M