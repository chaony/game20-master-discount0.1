local M = class("BountyMissionsHelpPopModel", LikeOO.OODataBase)


function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_parent_index = self.m_params.parent_index or 0
	self.m_heros = self.m_params.heros
	self.m_hero_ids = {}
	for k,v in pairs(self.m_heros) do
		table.insert( self.m_hero_ids, v)
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
			heros[k] = v
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

return M
