local M = class("UnionArtifactPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data or {}
	if self.m_data.guild then
		self.m_guild_lv = self.m_data.guild.level or 0
	else
		self.m_guild_lv = 0
	end
	self.m_cur_season = UserDataManager:getCurSeason()
	local guild_tripod = ConfigManager:getCfgByName("guild_tripod")
	self.m_guild_tripod_types = {}
	self.m_guild_tripod_type_cfg = {}
	self.m_guild_tripod_max_lv = {}
	for k,v in pairs(guild_tripod) do 
		local guild_tripod_type = k
		if self.m_guild_tripod_type_cfg[guild_tripod_type] == nil then
			self.m_guild_tripod_type_cfg[guild_tripod_type] = {}
			table.insert(self.m_guild_tripod_types, {guild_tripod_type = guild_tripod_type, name = v.name})
			self.m_guild_tripod_max_lv[guild_tripod_type] = 0
		end
		self.m_guild_tripod_type_cfg[guild_tripod_type]={id = k, cfg = v.config}
		self.m_guild_tripod_max_lv[guild_tripod_type] = math.max(self.m_guild_tripod_max_lv[guild_tripod_type], #v.config)
	end
	table.sort(self.m_guild_tripod_types, function(data1, data2) 
		return data1.guild_tripod_type < data2.guild_tripod_type
	end)
	self.m_select_index = #self.m_guild_tripod_types > 0 and 1 or -1
	self.m_heros_cid = {}
	local heros_data = UserDataManager.hero_data:getHerosData()
	for k,v in pairs(heros_data) do 
		self.m_heros_cid[v.id] = true
	end
end

--[[
1防御
2治疗
3内功输出
4外功输出
]]
function M:getTripodCfgByType(guild_tripod_type, model)
	model = model or 1
	local guild_tripod = ConfigManager:getCfgByName("guild_tripod")
	local type_cfg = guild_tripod[guild_tripod_type] or {}
	local lv = UserDataManager.tripods[tostring(guild_tripod_type)] or 0
	if model == 1 then
		local tripod_lv = lv
		local cfg = type_cfg.config[tripod_lv]
		if cfg and cfg.condition_lv > self.m_guild_lv then
			local condition_lv = cfg.condition_lv
			while condition_lv > self.m_guild_lv  do
				tripod_lv = tripod_lv - 1
				condition_lv = type_cfg.config[tripod_lv] and type_cfg.config[tripod_lv].condition_lv or 0
			end
			lv = tripod_lv
		end
	end
	
	local cfg = table.copy(type_cfg.config[lv]) or {}
	cfg.heroes_list = type_cfg.heroes_list
	cfg.name = type_cfg.name
	return cfg, lv
end

-- 计算当前层属性增加值
function M:computerUpAttrsValue(guild_tripod_type)
	local up_attrs = {}
	local guild_tripod = ConfigManager:getCfgByName("guild_tripod")
	local type_cfg = guild_tripod[guild_tripod_type] or {}
	local cur_cfg, lv = self:getTripodCfgByType(guild_tripod_type, 2)
	if lv > 0 then
		local max_lv = lv
		local min_lv = lv-1
		local min_attrs = nil
		local min_cfg = type_cfg.config[min_lv]
		while(min_cfg and min_cfg.order ~= 6) do
			min_lv = min_lv - 1
			min_cfg = type_cfg.config[min_lv]
		end
		if min_cfg then
			min_attrs = min_cfg.attr
		end
		local max_attrs = nil
		while(cur_cfg and cur_cfg.order ~= 6) do
			max_lv = max_lv + 1
			cur_cfg = type_cfg.config[max_lv]
		end
		if cur_cfg then
			max_attrs = cur_cfg.attr
		end

		if min_attrs then
			for i,v in ipairs(max_attrs) do
				local min_attr = min_attrs[i]
				up_attrs[i] = {v[1], v[2] - min_attr[2]}
			end
		else
			up_attrs = max_attrs
		end
	else
		up_attrs = type_cfg.config[6].attr
	end
	return up_attrs
end

function M:getSelectGuildTripod()
	local data = self.m_guild_tripod_types[self.m_select_index] or {}
	return data
end

function M:getGuildTripodResetCost()
	local data = self.m_guild_tripod_types[self.m_select_index] or {}
	local guild_tripod_cfg = self:getTripodCfgByType(data.guild_tripod_type, 2)
	return guild_tripod_cfg.reset_cost or {}
end

function M:getGuildTripodResetCostReturn()
	local rewards = {}
	local data = self.m_guild_tripod_types[self.m_select_index] or {}
	local guild_tripod_cfg = self:getTripodCfgByType(data.guild_tripod_type, 2)
	local cur_lv = UserDataManager.tripods[tostring(data.guild_tripod_type)] or 0
	local type_cfg = self.m_guild_tripod_type_cfg[data.guild_tripod_type] or {}
	for k,v in pairs(type_cfg.cfg) do
		if k <= cur_lv and next(v.lvup_cost) ~= nil then
			RewardUtil:mergeCfgReward(rewards, {v.lvup_cost})
		end
	end
	return rewards[1]
end

function M:getGuildTripodLvUpCost()
	local data = self.m_guild_tripod_types[self.m_select_index] or {}
	local guild_tripod_cfg = self:getTripodCfgByType(data.guild_tripod_type, 2)
	local next_lv = math.min((UserDataManager.tripods[tostring(data.guild_tripod_type)] or 0) + 1, self.m_guild_tripod_max_lv[data.guild_tripod_type] or 0)

	local type_cfg = self.m_guild_tripod_type_cfg[data.guild_tripod_type] or {}
	local cfg = type_cfg.cfg[next_lv]
	local cost = cfg.lvup_cost or {}
	return cost, cfg
end

function M:getHeroActivationFlag(cid)
	if self.m_heros_cid[cid] then
		return 1
	end
	return 0
end

function M:getHerosList(hero_list)
	local show_data = {}
	for i, v in ipairs(hero_list) do
		local activation_flag = self:getHeroActivationFlag(v)
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v)
		local hero_show_season = hero_cfg.season or 0
		if hero_show_season <= self.m_cur_season then
			table.insert(show_data, {item_data = {RewardUtil.REWARD_TYPE_KEYS.HEROS, v, 1}, activation_flag = activation_flag})
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.activation_flag > data2.activation_flag
	end)
	return show_data
end

--- 网络数据回调
--function M:netData(data, tag)
--	table.merge(self.m_data, data)
--end

--function M:callBack(data)
--	local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
--    if guild_id and guild_id > 0 then
--    	M.super.callBack(self,data)
--    else
--        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("union_str_0028"), delay_close = 2})
--        static_rootControl:closeAllViewPop()
--    end
--end

return M
