local M = class("HireMasterHeroPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_heros = self.m_params.heros
	self.m_apostle_heros = self.m_params.apostle_heros or {}
	self.m_lock_heros = table.copy(self.m_apostle_heros)
	self.m_hero_ids = {}
	for k,v in pairs(self.m_heros) do
		table.insert( self.m_hero_ids, k)
	end
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
			table.insert(heros, v)
		end
	end
	self.Filtrate_list = {}
	self.Filtrate_list = clone(heros)
	--UserDataManager.hero_data:heroIdsSort(self.Filtrate_list,"default")
end

--根据id获得英雄数据
function M:getHero(id)
	local data = self.m_heros[id]
	return data, UserDataManager.hero_data:getHeroConfigByCid(data.id)
end

function M:checkVacancy()
	if #self.m_apostle_heros >= 3 then
		return false
	else
		return true
	end
end

function M:checkIsSelect(id)
	for k,v in pairs(self.m_apostle_heros) do
		if v == id then
			return true
		end
	end
	return false
end

function M:addHero(id)
	table.insert(self.m_apostle_heros, id)
end

function M:removeHero(id)
	if self:checkLockHero(id) then
		return
	end
	for k,v in pairs(self.m_apostle_heros) do
		if v == id then
			table.remove(self.m_apostle_heros, k)
			break
		end
	end
end

function M:checkLockHero(id)
	for k,v in pairs(self.m_lock_heros) do
		if id == v then
			return true
		end
	end
	return false
end



return M
