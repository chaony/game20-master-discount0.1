local M = class("LibrarySelectModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_type_id = self.m_params.type_id
	self.m_hero_cid = self.m_params.hero_cid
	self.m_data = self.m_params.data
end

function M:getShowData()
	local show_data = {}
	local troops = self.m_data.troops or {}
	local lend_num = self.m_data.lend_num or {}
	local troops_data = troops[tostring(self.m_type_id)] or {}

	local select_c_ids = {}
	local troop_heroes = troops_data.troop_heroes or {} --  羁绊中的英雄
	local troop_heroes_oid = {}
	for k,v in pairs(troop_heroes) do
		troop_heroes_oid[v.hero_oid]= 1
		select_c_ids[v.user_id .. "-" ..  k .. "-" .. v.evo] = 1
	end
	local min_evo = self:getMinEvo()
	local assist_summaries = self.m_data.assist_summaries or {}
	for k,v in pairs(assist_summaries) do
		local user = v.user
		local uid = tostring(user.uid)
		local name = user.name
		local mercenarys = v.mercenarys or {}
		for k1,v1 in pairs(mercenarys) do
			if v1.evo >= min_evo then
				local select_key = uid .. "-" .. v1.id .. "-" .. v1.evo
				if v1.id == self.m_hero_cid and (troop_heroes_oid[k1] or not select_c_ids[select_key]) then
					local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, v1.id, 0})
					data.quality = v1.evo
					data.hero_id = k1
					data.uid = uid
					data.user_name = name
					data.select_flag = troop_heroes_oid[k1] ~= nil
					data.lend_num = lend_num[uid] or 0
					table.insert(show_data, data)
					select_c_ids[select_key] = 1
				end
			end
		end
	end

	local function filterFunc(data, cfg)
		return cfg.id == self.m_hero_cid and data.evo >= min_evo
	end
	local own_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	local heros_id = UserDataManager.hero_data:getHerosIdByFilterFunc(filterFunc)
	for k,v in pairs(heros_id) do
		local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		local select_key = own_uid .. "-" .. hero_data.id .. "-" .. hero_data.evo
		if troop_heroes_oid[v] or not select_c_ids[select_key] then
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.hero_id = v
			data.uid = own_uid
			data.user_name = UserDataManager.user_data:getUserStatusDataByKey("name")
			data.select_flag = troop_heroes_oid[v] ~= nil
			data.lend_num = 0
			table.insert(show_data, data)
			select_c_ids[select_key] = 1
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.quality > data2.quality
	end)
	return show_data
end

function M:getHeroName()
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_hero_cid)
	return Language:getTextByKey(cfg and cfg.name or "")
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
    table.merge(self.m_data, data)
end

return M
