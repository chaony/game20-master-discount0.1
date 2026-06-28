local M = class("HeavenEarthModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_normal_array_tab = ConfigManager:getCfgByName("normal_array")
	self.m_teams = {} --team = {id, name, array, state}
	--重新构建阵法组数据
	for k, v in pairs(self.m_normal_array_tab) do
		--local team_id = k
		local index = #self.m_teams + 1
		self.m_teams[index] = {}
		self.m_teams[index].id = k
		self.m_teams[index].array = table.keys(v)
		local function sortFunc(a, b)
			return a < b
		end
		table.sort(self.m_teams[index].array, sortFunc)
		local id = self.m_teams[index].array[1]
		self.m_teams[index].name = v[id].team_name
		self.m_teams[index].icon = v[id].icon
		self.m_teams[index].state = self:checkActiveTeam(v[id].activate_array)
		id = self.m_teams[index].array[#self.m_teams[index].array]
		self.m_teams[index].cond_array = self:formatCond(v[id].activate_array)
	end
	local function sortFunc(team1, team2)
		return team1.id < team2.id
	end
	table.sort(self.m_teams, sortFunc)
end

--获得阵法
function M:getArray(id)
	for k, v in pairs(self.m_normal_array_tab) do
		for kk, vv in pairs(v) do
			if kk == id then
				return vv
			end
		end
	end
	return nil
end

--获得阵法组等级
function M:getTeamLV(team_id)
	local lv = UserDataManager.m_normal_teams_lv[tostring(team_id)] or 1
	return lv
end

--格式化阵法条件
--为了处理类型4的情况
function M:formatCond(cond_array)
	local new_cond_array = {}
	for i, v in pairs(cond_array) do
		if v[1] == 4 and v[4] > 1 then
			for j = 1, v[4] do
				new_cond_array[#new_cond_array + 1] = {v[1], v[2], v[3], 1}
			end
		else
			new_cond_array[#new_cond_array + 1] = v
		end
	end
	return new_cond_array
end

--阵法组条件达成
function M:checkActiveTeam(cond_array)
	--local heroes_oid = table.copy(UserDataManager.hero_data:getHerosId())
	local heroes_flag = {} --记录已经统计过的侠客id，目的是为了去重，同id的侠客只能算一次
	for l, cond in pairs(cond_array) do
		if cond[1] == 4 then
			local is_active = self:isReachHeroSPNum(cond[2], cond[3], cond[4])
			if is_active == false then
				return 0
			end
		else
			local is_active = self:checkActiveCondition(cond, heroes_flag)
			if is_active == false then
				return 0
			end
		end
	end
	return 1
end

--条件达成
function M:checkActiveCondition(cond, heroes_flag)
	local heroes_oid = UserDataManager.hero_data:getHerosId()
	for k,v in pairs(heroes_oid) do
		local hero, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		if hero and hero_cfg and heroes_flag[hero_cfg.id] == nil then
			if cond[1] == 1 then --性别
				if cond[3] ==  hero_cfg.sex then
					heroes_flag[hero_cfg.id] = true
					return true
				end
			elseif cond[1] == 2 then --职业
				if cond[3] == hero_cfg.role_type then
					heroes_flag[hero_cfg.id] = true
					return true
				end
			elseif cond[1] == 3 then --特定英雄
				if cond[2] == hero_cfg.id and cond[3] <= hero.evo then
					heroes_flag[hero_cfg.id] = true
					return true
				end
			end
		end
	end
	return false
end

--到达某个品质的sp类型侠客数量
function M:isReachHeroSPNum(sp_type, evo, num)
	local heroes_oid = UserDataManager.hero_data:getHerosId()
	local sum = 0
	local heroes_flag = {} --记录已经统计过的侠客id，目的是为了去重，同id的侠客只能算一次
	for k,v in pairs(heroes_oid) do
		local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
		--if cfg.is_sp and cfg.is_sp == sp_type then
		if cfg.is_sp and cfg.is_sp == sp_type and hero.evo >= evo then
			local flag = heroes_flag[cfg.id]
			if flag == nil then
				heroes_flag[cfg.id] = true
				sum = sum + 1
				if sum >= num then
					return true
				end
			end
		end
	end
	return false
end

--获得效果描述
function M:getEffectText(id, level)
	local cfg = ConfigManager:getCfgByName("normal_effect")
	local c = cfg[id]
	if c ~= nil and c[level] ~= nil then
		return c[level].array_describe
	end
	return nil
end

--获得升级消耗
--有通用道具逻辑
function M:getUpgradeCost(team_id, level)
	local cfg = ConfigManager:getCfgByName("normal_team_level")
	local c = cfg[team_id]
	if c == nil or c[level] == nil then
		return nil
	end
	local cost_array = {}
	for k,v in ipairs(c[level].consume) do
		local cost = self:getUpgradeComCost(v)
		if cost == nil then
			cost_array[#cost_array + 1] = v
		else
			cost_array[#cost_array + 1] = cost
			local new_num = v[3] - cost[3]--去掉通用道具的数量
			if new_num > 0 then --本身道具有几个就显示几个，否则就不显示了
				cost_array[#cost_array + 1] = {v[1], v[2], new_num}
				--cost_array[#cost_array + 1] = v
			end
		end
	end
	return cost_array
end

--获得通用道具数据[type, id, num]
--本身印记是否足够，不够用的话，加上通用印记，如果通用印记也不足，就还显示本身印记
--返回nil，代表不需要增加通用道具，有可能是本身道具足够、也可能是通用道具也不够
function M:getUpgradeComCost(data)
	if data[1] ~= RewardUtil.REWARD_TYPE_KEYS.ITEM then
		return nil
	end
	local cost = RewardUtil:getProcessRewardData(data)
	if cost.user_num >= cost.data_num then
		return nil
	end
	local com_item_id = self:getUpgradeComCostId(data[2])
	if com_item_id == nil then
		return nil
	end
	local need_num = cost.data_num - cost.user_num
	local com_data = {RewardUtil.REWARD_TYPE_KEYS.ITEM, com_item_id, need_num}
	local com_cost = RewardUtil:getProcessRewardData(com_data)
	if com_cost.user_num >= com_cost.data_num then
		return com_data
	end
	return nil
end

--是否可以用通用道具代替
--common表836配置了才可以用通用道具代替
function M:getUpgradeComCostId(item_id)
	local common_cfg = ConfigManager:getCfgByName("common")
	local cfg_836 = common_cfg[836]
	if cfg_836 == nil or cfg_836.value == nil then
		return nil
	end
	local index = table.keyof(cfg_836.value, item_id)
	if index == nil then
		return nil
	end
	return cfg_836.value[1] --首数据即为通用道具id
end

--升级更新
function M:updateUpgrade(team_id, level)
	UserDataManager.m_normal_teams_lv[tostring(team_id)] = level
end

return M