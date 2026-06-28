local M = class("UnionWarSituationModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)
    self:getData()    
end

function M:onEnter()
    self.m_last_report = self.m_params.last_report or {}
end

function M:getShowData()
    local cells = self.m_last_report.cells or {}
    local vs = self.m_last_report.vs or {}
    local left_gid = vs[1] or ""
    local right_gid = vs[2] or ""
    local show_data = {}
    local guild_war_map_cfg = ConfigManager:getCfgByName("guild_war_map")
    for k, v in pairs(cells) do
        local cell_id = tonumber(k)
        local win = v.win or 0 -- 0:没有胜利的公会
        local t_num = v.t_num or {} -- 队伍数量
        local left_t_num = t_num[tostring(left_gid)] or 0
        local right_t_num = t_num[tostring(right_gid)] or 0
        local left_win = left_gid == win
        local right_win = right_gid == win
        table.insert(show_data, {data = v, cell_id = cell_id, cell_cfg = guild_war_map_cfg[cell_id] or {}, left_t_num = left_t_num, right_t_num = right_t_num, left_win = left_win, right_win = right_win})
    end
    return show_data
end

function M:getGuildInfo(idx)
    local vs = self.m_last_report.vs or {}
    local gid = vs[idx] or ""
    local guild_info = self.m_last_report.guild_info or {}
    local guild_info_item = guild_info[tostring(gid)] or {}
    local guild_flag_cfg = ConfigManager:getCfgByName("guild_flag")
    local guild_flag_cfg_item = guild_flag_cfg[guild_info_item.flag] or {}
    return guild_info_item, guild_flag_cfg_item.icon
end

return M