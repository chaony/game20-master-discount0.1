local M = class("MazeStageHerosModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_maze_data = self.m_params.data
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
		if hero_data then
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

return M
