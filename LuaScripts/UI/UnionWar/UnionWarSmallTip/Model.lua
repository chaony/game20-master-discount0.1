local M = class("UnionWarSmallTipModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)
    self:getData("gvg_cell_info", {cell_id = self.m_params.cell_id})
end

function M:onEnter()
    self.m_cell_id = self.m_params.cell_id
    self.m_union_war_data = self.m_params.union_war_data
    self.m_show_hero_data = self:initShowHeroData()
    self.m_difficulty = 0
    self.m_difficulty_star = 3
end

function M:getGuildWarMapCfg()
    local start_index = self:getCellStartIndex()
    local guild_war_map_cfg = ConfigManager:getCfgByName("gw_map")
    if start_index == 0 then
        return guild_war_map_cfg[self.m_cell_id] or {}
    else
        return guild_war_map_cfg[start_index - self.m_cell_id] or {}
    end
end

function M:getTeamNum()
    return self.m_data.team_num or 0
end

--难度星级加成
function M:getEnemyAddition(stae_id)
    local common = ConfigManager:getCfgByName("common")
    local enemybuf = common[498].value[stae_id]
    return enemybuf
end

--奖励加成
function M:getRewardAddition(stae_id)
    local common = ConfigManager:getCfgByName("common")
    local enemybuf = common[490].value[stae_id]
    return enemybuf
end

--初始化显示英雄数据
function M:initShowHeroData()
    self.m_total_combat = 0
    local show_data = {}
    local team = self.m_data.team or {}
    local heros = self.m_data.heros or {}
    local dyns = self.m_data.dyns or {} -- 战斗开始英雄数据动态信息
    for k, v in pairs(team) do
        local hero_data = heros[v]
        if hero_data then
            local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
            data.quality = hero_data.evo
            data.card_id = v
            data.hero_data = hero_data
            data.dyns = dyns[v] or {}
            table.insert(show_data, data)
            self.m_total_combat = self.m_total_combat + hero_data.combat
        end
    end
    return show_data
end

function M:getShowHeroData()
    return self.m_show_hero_data or {}
end

function M:isCanBattle()
    local atk_use = self.m_union_war_data.atk_use or {}
    return #atk_use < 3
end

function M:getFormationIndex()

    local atk_use = self.m_union_war_data.atk_use or {}
    --第一次战斗，可以编辑队伍
    if #atk_use == 0 then
        return 1
    end

    local atk_teams = UserDataManager:getGvgTeamsByKey("atk_teams")
    for i = 1, 3 do
        local index = table.indexof(atk_use, i)
        --队伍没出战
        if not index then
            local sel_team = atk_teams[tostring(i)]

            if sel_team and sel_team.team then
                for idx = 1, 5 do
                    if sel_team.team[idx] ~= "" then
                        return i
                    end
                end
            end
        end
    end

    return nil

end

function M:isOwn()
    local cells = self.m_union_war_data.cells or {}
    local cell_data = cells[tostring(self.m_cell_id)] or {}
    local owner = cell_data.owner
    local own_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    return owner == own_guild_id
end

function M:getCellStartIndex()
    return GameUtil:getUnionWarCellStartIndex(self.m_union_war_data)
end

return M
