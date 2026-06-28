local M = class("GuJianQiTanMazeHerosModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_maze_data = self.m_params.data
	self.m_death_hero_oids = self.m_params.death_hero_oids or {}
end

function M:getShowHeroData()
	-- local team = UserDataManager.hero_data:getTeamByKey("maze") or {} -- 当前队伍
	local dyns = self.m_maze_data.dyns or {} -- 战斗开始我方英雄数据动态信息
	local hero_ids = table.copy(UserDataManager.hero_data:getHerosId())
	local assist_heros = self.m_maze_data.assist_heros or {} --雇佣的英雄
	for k,v in pairs(assist_heros) do
		table.insert(hero_ids, k)
	end
	UserDataManager.hero_data:heroIdsSort(hero_ids,"lv", assist_heros)
	local show_data = {}
	local heros = self.m_maze_data.heros or {}
	for k,v in pairs(hero_ids) do
		local hero_data = assist_heros[v] or UserDataManager.hero_data:getHeroDataById(v)
		local is_death = self:heroIsDeath(v)
		if hero_data and not is_death then
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.card_id = v
			data.dyns = dyns[v] or {}
			data.hero_data = hero_data
			table.insert(show_data, data)
		end
	end
	return show_data
end

function M:checkIsDie()
	local dyns = self.m_maze_data.dyns or {} -- 战斗开始我方英雄数据动态信息
	local assist_heros = self.m_maze_data.assist_heros or {} --雇佣的英雄
	local is_die = false
	for k,v in pairs(dyns) do
		if v.hp_pct <= 0 then
			is_die = true
			break
		end
	end
	if is_die == true then
		local cost = ConfigManager:getCommonValueById(47)
		local cost_data = RewardUtil:getProcessRewardData(cost[1])
		if cost_data.user_num <= 0 then
			is_die = false
		end
	end
	return is_die
end

function M:heroIsDeath(oid)
    local flag = false
	for k,v in pairs(self.m_death_hero_oids) do
		if v == oid then
			return true
		end
	end
    return flag
end

return M
