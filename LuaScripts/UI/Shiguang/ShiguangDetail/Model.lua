local M = class("ShiguangDetailModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cell_data = self.m_params.data
	self.m_open_flag = self.m_cell_data.open_flag
	self.m_show_hero_data = self:initShowHeroData()
end

function M:initShowHeroData()
	self.m_total_combat = 0
	local show_data = {}
	local def_team = self.m_cell_data.def_team or {}
	local heros = self.m_cell_data.heros or {}
	local dyns = self.m_cell_data.dyns or {} -- 战斗开始英雄数据动态信息
	for k,v in pairs(def_team) do
		local hero_data = heros[v]
		if hero_data then
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.card_id = v
			data.hero_data = hero_data
			data.dyns = dyns[v] or {}
			table.insert(show_data, data)
			self.m_total_combat = self.m_total_combat + hero_data.combat
		end
	end
	return show_data
end

function M:getShowHeroData()
	return self.m_show_hero_data or {}
end

function M:getShowRewardData()
	local show_data = {}
	local gift = self.m_cell_data.gift or {}
	return gift
end

return M
