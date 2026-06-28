local M = class("UnionWarDispatchModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_data = self.m_params.data
end

function M:getShowTeams()
    local teams = UserDataManager:getGvgTeamsByKey("atk_teams")
    local data = {}
    for i = 1, 3 do
        local item_data = {}
        if teams[tostring(i)] ~= nil then
            item_data = teams[tostring(i)]
        end
        item_data.team_id = tostring(i)
        table.insert(data, item_data)
    end
    return data
end

function M:getHerosDataByTeam(team)
    local combat = 0
    team = team or {}
    local team_heros_data = {}
    for index = 1,5 do
        local hero_id = team[index] or ""
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
        if hero_data == nil then
            hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataByDataAndId(self.m_data.atk_heros, hero_id)
        end
        local data = nil
        if hero_data and hero_cfg then
            data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
            data.quality = hero_data.evo
            data.card_id = hero_id
            data.hero_data = hero_data
            combat = hero_data.combat + combat
        end
        team_heros_data[index] = data or {}
    end
    return team_heros_data, combat
end

function M:teamIsLock()
    return self.m_data.atk_lock
end

function M:teamIsUseById(id)
    local atk_use = self.m_data.atk_use or {} -- [1, 2, 3], 是否过的队伍id
    local atk_star = self.m_data.atk_star or {} -- 队伍攻击获得的星
    local index = table.indexof(atk_use, id)
    local user_flag = false
    local star = 0
    if index then
        user_flag = true
        star = atk_star[tostring(id)] or 0
    end
    return user_flag, star
end

return M