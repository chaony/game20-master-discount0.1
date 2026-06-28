local M = class("UnionWarMainModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_data = self.m_params
    self:getData()
end

function M:onEnter()
    self.m_simulated_battle_flag = UserDataManager.local_data:getUserDataByKey("simulated_battle_flag", false)
end

-- 获取公会数据，参数1表示自己帮会，2表示敌方数据
function M:getUnionData(index)
    local own_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    local guild_id = nil
    for i, v in ipairs(self.m_data.vs) do
        if index == 1 then
            if own_guild_id == v then
                guild_id = v
            end
        else
            if own_guild_id ~= v then
                guild_id = v
            end
        end
    end
    return self.m_data.guild_info[tostring(guild_id)], guild_id
end

function M:calculateLeftTeamsNum()
    local num = 0
    return num
end

function M:getWinnerGuild()
    local guild_data = nil
    local winner = self.m_data.winner or 0
    if winner > 0 then
        guild_data = self.m_data.guild_info[tostring(winner)]
    end
    return guild_data
end

function M:changeSimulatedBattleFlag()
    self.m_simulated_battle_flag = not self.m_simulated_battle_flag
    UserDataManager.local_data:setUserDataByKey("simulated_battle_flag", self.m_simulated_battle_flag)
end

function M:teamIsUseById(id)
    local atk_use = self.m_data.atk_use or {} -- [1, 2, 3], 是否过的队伍id
    local index = table.indexof(atk_use, id)
    local user_flag = false
    if index then
        user_flag = true
    end
    return user_flag
end

--判断赛季奖励是否显示
function M:getSeasonRewardIsDisPlay()
    local open_condition = ConfigManager:getCfgByName("open_condition")
    local unloke_season = open_condition[215].season_unlock
    local server_unlock_season = 0
    local season_data = UserDataManager.m_season_data or {}
    if season_data and next(season_data) and season_data.season then
        server_unlock_season = season_data.season
    end
    if server_unlock_season < unloke_season then --小于配置赛季，则不显示
        return false
    end
    return true
end

return M
