local M = class("UnionWarRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)
    self:getData()    
end

function M:onEnter()
    self.m_sel_tab_index = self.m_params.isActive_num or 1
    local ranks = self:getRankRewards()
    self.rank_rewards = #ranks
end

function M:getDayReward()
    local huoyue_reward = ConfigManager:getCommonValueById(349) --活跃奖励
    local kill_reward = ConfigManager:getCommonValueById(356) --击杀奖励
    local kill_max_num = ConfigManager:getCommonValueById(394) --击杀次数上限
    local max_reward = table.copy(kill_reward[1])
    max_reward[3] = max_reward[3] * kill_max_num
    return huoyue_reward, kill_reward, {max_reward}
end

function M:getBoutReward()
    local win_union_reward = ConfigManager:getCommonValueById(350) --胜利帮会
    local lose_union_reward = ConfigManager:getCommonValueById(351) --失败帮会
    local guild_war_reward = ConfigManager:getCfgByName("guild_war_reward") or {}
    local cur_season =UserDataManager.m_active_cross_sid or UserDataManager:getCurSeason() --跨服组最大赛季 or 当前赛季
    local reward_season = guild_war_reward[cur_season] ~= nil and cur_season or 0
    if guild_war_reward[cur_season] == nil then
        for i, v in pairs(guild_war_reward) do
            if i < cur_season and i >= reward_season then
                reward_season = i
            end
        end
    end
    local tab_info = guild_war_reward[reward_season] or {}
    local win_per_reward = tab_info[1].reward --胜利个人
    local lose_per_reward = tab_info[2].reward --失败个人
    return win_union_reward, win_per_reward, lose_union_reward,lose_per_reward
end

function M:getSeasonReward()
    local reward_tab = ConfigManager:getCfgByName("guild_war_ranking_reward")
    return reward_tab
end

function M:getRankRewards()
	local tab = ConfigManager:getCfgByName("guild_war_ranking_reward")
    local cur_season = UserDataManager.m_active_cross_sid or UserDataManager:getCurSeason() --跨服组最大赛季 or 当前赛季
	local new_tab = {}
    local reward_season = tab[cur_season] ~= nil and cur_season or 0 
    if tab[cur_season] == nil then
        for i, v in pairs(tab) do
            if i < cur_season and i >= reward_season then
                reward_season = i
            end
        end
    end
    local tab_info = tab[reward_season] or {}
	for k,v in pairs(tab_info) do
		v.id = k
        table.insert( new_tab, v)
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getRankScope(index)
	if index > 1 then
		local ranks = self:getRankRewards()
		local last_rank = ranks[index-1]
		if last_rank then
			return last_rank.id + 1
		end
	end
	return 0
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