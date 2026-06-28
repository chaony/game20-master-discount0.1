local M = class("GuJianQiTanMazeHeroSelectSubModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_select_index = -1
	self.m_cell_data = self.m_params.data
	--self.m_open_flag = self.m_params.open_flag
	self.m_callBack = self.m_params.callBack
	self.m_engageHeroId = self.m_params.engageHeroId
	self.m_assist_heros = self.m_params.m_assist_heros
	self.m_engageHeroId = self.m_params.engageHeroId
	self:initData()
end

function M:initData()
	self.m_show_hero_data = self:initShowHeroData()
end

function M:initShowHeroData()
	local show_data = {}
	for k,hero_data in pairs(self.m_assist_heros) do
		if hero_data then
			local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.hero_id = k
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
