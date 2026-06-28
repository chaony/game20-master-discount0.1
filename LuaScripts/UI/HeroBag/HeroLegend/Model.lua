local M = class("HeroLegend", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end



function M:onEnter()
	self.m_hero_id = self.m_params.hero_id
	self.m_hero_data = self.m_params.hero_data
	self.hero_legend_tab = self:getHeroLegend()
	self.m_max_legend = math.ceil((#self.hero_legend_tab+1)/2) 
	self.m_is_go_last = self.m_params.go_last or false
	--Logger.logError(self.m_hero_data)
end

function M:getHeroLegend()
	local hero_fetters_tab = ConfigManager:getCfgByName("hero_fetters")
	local fetter_data = UserDataManager.m_friendliness[tostring(self.m_hero_data.id)] or {point=0,lv=0}
	local legend_tab = {}
	self.all_legend_tab = {}
	self.next_lv = 0
	if hero_fetters_tab[self.m_hero_data.id] then
		local fetter_hero_cfg = hero_fetters_tab[self.m_hero_data.id] or {}
		local max_fetter = (#fetter_hero_cfg)
		for i = 0, max_fetter do
			if i <= fetter_data.lv then
				if fetter_hero_cfg[i] and fetter_hero_cfg[i].legend_id then
					table.insertto(legend_tab, fetter_hero_cfg[i].legend_id)
					table.insertto(self.all_legend_tab, fetter_hero_cfg[i].legend_id)
				end
			else
				if fetter_hero_cfg[i] and fetter_hero_cfg[i].legend_id then
					if self.next_lv == 0 and next(fetter_hero_cfg[i].legend_id) ~= nil then
						self.next_lv = i
					end
					table.insertto(self.all_legend_tab, fetter_hero_cfg[i].legend_id)
				end
			end
		end
	end
	return legend_tab
end

function M:getLegendCfg(id)
	local hero_legend_tab = ConfigManager:getCfgByName("hero_legend")
	local hero_legend_data = hero_legend_tab[self.m_hero_data.id]
	return hero_legend_data[id]
end

return M
