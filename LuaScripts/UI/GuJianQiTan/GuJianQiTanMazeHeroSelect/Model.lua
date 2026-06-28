local M = class("GuJianQiTanMazeHeroSelectModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_select_index = -1
	self.m_cell_data = self.m_params.data
	self.m_open_flag = self.m_params.open_flag
	self.m_callBack = self.m_params.callBack
	self.m_assist_heros = self.m_params.assist_heros
	self:initData(self.m_data)
end

function M:initData(data)
	self.m_data = data or self.m_data
	self.m_show_hero_data = self:initShowHeroData()
end

function M:initShowHeroData()
	local show_data = {}
	local def_team = self.m_cell_data.def_team or {}
	local heros = self.m_cell_data.heros or {}
	for k,v in pairs(def_team) do
		local hero_data = heros[v]
		if hero_data then
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.hero_id = v
			data.hero_data = hero_data
			table.insert(show_data, data)
		end
	end
	return show_data
end

function M:getHeroDataByid(id)
	local heros = self.m_cell_data.heros or {}
	return heros[id] or {}
end

function M:getShowHeroData()
	return self.m_show_hero_data or {}
end

return M
