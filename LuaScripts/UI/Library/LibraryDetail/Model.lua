local M = class("LibraryDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_type_id = self.m_params.type_id
	self.m_data = self.m_params.data
	self.m_min_evo = self:getMinEvo()
end

function M:getShowData()
	local show_data = {}
	local troops = self.m_data.troops or {}
	local teahouse = ConfigManager:getCfgByName("teahouse")
	for k,v in pairs(teahouse) do
		if v.type_id == self.m_type_id then
			local attr = v.attr or {}
			local attr_des = ""
			for k1,v1 in ipairs(attr) do
				local attr_cfg = GameUtil:getAttrCfg(v1[1])
				local name = Language:getTextByKey(attr_cfg.name)
				local is_percent = attr_cfg.is_percent or 0
				local attr_text = ""
				if k1 == 906 then -- 策划未统一
					attr_text = tostring(v1[2]) .. "%"
				else
					attr_text = is_percent == 1 and (tostring(v1[2]*100) .. "%") or tostring(v1[2])
				end
				attr_des = attr_des .. (k1 > 1 and " " or "") .. name .. "+" .. attr_text
			end
			local hero_ids = v.hero_ids or {}
			local evo = v.evo or 99
			self.m_min_evo = math.min(self.m_min_evo, evo)
			local total_count = #hero_ids
			local activation_count = 0
			local troops_data = troops[tostring(v.type_id)] or {}
			local troop_heroes = troops_data.troop_heroes or {} --  羁绊中的英雄
			for k,v in pairs(troop_heroes) do
				if v.evo >= evo then
					activation_count = activation_count + 1
				end
			end
			local troop_ids = troops_data.troop_ids or {} --  激活的羁绊id
			local index = table.indexof(troop_ids, k)
			local activation = index ~= nil
			table.insert(show_data, {id = k, data = troops_data, cfg = v, attr_des = attr_des, total_count = total_count, activation_count = activation_count, activation = activation})
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.id < data2.id
	end)
	return show_data
end

function M:getHeroShowData()
	local show_data = {}
	local troops = self.m_data.troops or {}
	local teahouse = ConfigManager:getCfgByName("teahouse")

	local all_heros = self:getAllHeroData()
	for k,v in pairs(teahouse) do
		if v.type_id == self.m_type_id then
			local hero_ids = v.hero_ids or {}
			local evo = v.evo or 99
			local troops_data = troops[tostring(v.type_id)] or {}
			local troop_heroes = troops_data.troop_heroes or {} --  羁绊中的英雄
			for k1,v1 in pairs(hero_ids) do
				local troop_heroes_data = troop_heroes[tostring(v1)]
				local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, v1, 0})
				data.quality = troop_heroes_data and troop_heroes_data.evo or evo
				data.activation = troop_heroes_data ~= nil
				if not data.activation and all_heros[v1] and #all_heros[v1] > 0 then
					data.show_add = true
				else
					data.show_add = false
				end
				table.insert(show_data, data)
			end
			break
		end
	end
	return show_data
end

function M:getAllHeroData()
	local show_data = {}
	local troops = self.m_data.troops or {}
	local lend_num = self.m_data.lend_num or {}
	local troops_data = troops[tostring(self.m_type_id)] or {}
	local troop_heroes = troops_data.troop_heroes or {} --  羁绊中的英雄
	local troop_heroes_oid = {}
	for k,v in pairs(troop_heroes) do
		troop_heroes_oid[v.hero_oid]= 1
	end
	local assist_summaries = self.m_data.assist_summaries or {}
	for k,v in pairs(assist_summaries) do
		local user = v.user
		local uid = user.uid
		local name = user.name
		local mercenarys = v.mercenarys or {}
		local cur_lend_num = lend_num[uid] or 0
		if cur_lend_num < GlobalConfig.ASSIST_SUMMARIES_LIMIT_NUM then
			for k1,v1 in pairs(mercenarys) do
				if troop_heroes_oid[k1] == nil then
					if show_data[v1.id] == nil then
						show_data[v1.id] = {}
					end
					table.insert(show_data[v1.id], k1)
				end
			end
		end
	end

	local heros_id = UserDataManager.hero_data:getHerosId()
	for k,v in pairs(heros_id) do
		local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		if troop_heroes_oid[v] == nil and hero_data.evo >= self.m_min_evo then
			if show_data[hero_data.id] == nil then
				show_data[hero_data.id] = {}
			end
			table.insert(show_data[hero_data.id], v)
		end
	end

	return show_data
end

function M:getMinEvo()
	local min_evo = 99
	local teahouse = ConfigManager:getCfgByName("teahouse")
	for k,v in pairs(teahouse) do
		if v.type_id == self.m_type_id then
			local evo = v.evo or 99
			min_evo = math.min(min_evo, evo)
		end
	end
	return min_evo
end

function M:initData(data)
	table.merge(self.m_data, data or {})
end

return M
