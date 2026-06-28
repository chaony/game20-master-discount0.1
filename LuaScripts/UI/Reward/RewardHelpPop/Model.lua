local M = class("RewardHelpPopModel", LikeOO.OODataBase)


function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_parent_index = self.m_params.parent_index or 0
	self.m_heros = self.m_params.heros
	self.m_select_oid = ""
	self.m_hero_ids = {}
	local m_heros = UserDataManager.hero_data:getHerosId()
	for k,v in pairs(m_heros) do
		if self:filtrateHero(v) == false then
			table.insert(self.m_hero_ids, v)
		end
	end
end

function M:filtrateHero(oid)
	for i,v in ipairs(self.m_heros) do
		if v.oid == oid then
			return true
		end
	end
	return false
end

--根据种族和属性筛选英雄
function M:getHeroByRace(race)
	if race == 0 then
		self.Filtrate_list = {}
		self.Filtrate_list = clone(self.m_hero_ids)
		return
	end
	local heros = {}
	for k,v in pairs(self.m_hero_ids) do
		local l_hero_data, l_hero_cfg = self:getHero(v)
		if race == 0 or race == l_hero_cfg.race then
			--heros[k] = v
			table.insert( heros, v)
		end
	end
	self.Filtrate_list = {}
	self.Filtrate_list = clone(heros)
	--UserDataManager.hero_data:heroIdsSort(self.Filtrate_list,"default")
end

--根据id获得英雄数据
-- function M:getHero(id)
-- 	local data = self.m_heros[id]
-- 	return data, UserDataManager.hero_data:getHeroConfigByCid(data.id)
-- end

function M:getHero(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end


return M
