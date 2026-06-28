local M = class("BudoServerHeroPopModel", LikeOO.OODataBase)

local __max_rank_count = 100
function M:onCreate()
	M.super.onCreate(self)
	self:getData("tower_active_show_hero")
end

function M:onEnter()
	self.m_hero_map = self.m_data.heros or {}
	self.m_heros = table.values(self.m_hero_map)
	table.sort(self.m_heros,function(a, b)
		return a.hero.combat > b.hero.combat
	end)
end

return M
