local M = class("MasterSelectHeroPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_fates = UserDataManager:getFatesInfo()
	self.m_open_type = self.m_params.open_type or "master"
	self.m_select_hero_id = self.m_params.hero_id or ""
	self.m_old_hero_id = self.m_params.hero_id or ""
	self.m_master_id = self.m_params.master_id
	self.m_slaves_pos = self.m_params.slaves_pos
	self.m_total_hero = self:getHeroData()
end

--切换英雄列表
function M:switchHeroList(race)
	self.m_cur_race = race
	local hero_list = {}
	hero_list = self:filtrateHero(race)
	return hero_list
end

--获取所有英雄信息
function M:getHeroData()
	local all_hero =  UserDataManager.hero_data:getHerosData()
	local hero_data = {}
	for i, v in pairs(all_hero) do
		local hero_cfg =  UserDataManager.hero_data:getHeroConfigByCid(v.id)

		if self.m_open_type == "master" and self:heroIsLight(v.oid) and hero_oid ~= self.m_select_hero_id then
			table.insert(hero_data,v)
		elseif self.m_open_type == "slaves" and not self:heroIsMaster(v.oid, true) and hero_cfg.evo > 4 then
			table.insert(hero_data,v)
		end
	end
	table.sort(hero_data,function(data1,data2)
		if data1.combat == data2.combat then
			if data1.level == data2.level then
				return data1.evo > data2.evo
			else
				return data1.level > data2.level
			end
		else
			return data1.combat > data2.combat
		end
	end)
	return hero_data
end

--判断英雄是否领悟
function M:heroIsLight(hero_oid)
	for i, v in pairs(self.m_fates) do
		for hero_i, hero_v in pairs(v.heros) do
			if hero_v == hero_oid then
				return true
			end
		end
	end
	return false
end
--is_master 只判断是不是宗师 is_slaves 只判断是不是随从
function M:heroIsMaster(hero_oid, is_master, is_slaves)
	if hero_oid == self.m_old_hero_id then
		return false
	end
	local master_data = UserDataManager.m_fate_master
	for i, v in pairs(master_data) do
		if not is_slaves then
			if v.master == hero_oid then
				return true
			end
		end
		if not is_master then
			for hero_i, hero_v in pairs(v.slaves) do
				if hero_v == hero_oid then
					return true
				end
			end
		end
	end
	return false
end

--过滤 全部英雄列表
function M:filtrateHero(race_id)
	--获取全部英雄列表
	local hero_list = self.m_total_hero
	--如果种族是 0 表示 不筛选
	if race_id == 0 then
		return hero_list
	end
	local heros = {}
	for k,v in pairs(hero_list) do
		--获取英雄配置
		local h_data, hero_cfg =  UserDataManager.hero_data:getHeroDataById(v.oid)
		--如果种族一致就加入到列表中
		if race_id == hero_cfg.race then
			table.insert(heros, h_data)
		end
	end
	--根据等级排序
	table.sort(heros,function(data1,data2)
		if data1.combat == data2.combat then
			if data1.level == data2.level then
				return data1.evo > data2.evo
			else
				return data1.level > data2.level
			end
		else
			return data1.combat > data2.combat
		end
		
		--if data1.hero_state == data2.hero_state then
		--	return data1.hero_state > data2.hero_state
		--else
		--	return data1.hero_state < data2.hero_state
		--end
	end)
	return heros
end

--以是否拥有为根据排序
function M:sortHeroTabByGet(tab)
	table.sort(tab, function(a, b) 
		local get_1 = self:hasHeros(a.id) and 1 or 0
		local get_2 = self:hasHeros(b.id) and 1 or 0
		return get_1 > get_2
	end)
end

function M:getHeroDataById(hero_data)
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	local itemData = RewardUtil:getHeroConfigData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, 1})
	itemData.quality = hero_data.evo;
	itemData.oid = hero_data.oid;
	return itemData;
end

return M
