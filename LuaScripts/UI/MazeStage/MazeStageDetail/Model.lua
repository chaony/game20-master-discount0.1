local M = class("MazeStageDetailModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cell_data = self.m_params.data
	self.m_open_flag = self.m_params.open_flag
	self.m_mver = self.m_params.mver;
	self.m_callBack = self.m_params.callBack;
	self.m_cell_id = self.m_params.cell_id;
	self.m_heros_combat = self.m_params.heros_combat
	--当前层
	self.m_cur_floor = self.m_params.cur_floor
	--最大层
	self.m_max_floor = self.m_params.max_floor
	self.m_show_hero_data = self:initShowHeroData()
end

--是否可以快速战斗
function M:canQuickBattle()
	local result = false;
	--if self.m_cur_floor < self.m_max_floor then
	--	--迷宫阵容总战力
	result = self.m_total_combat <  self.m_heros_combat * (ConfigManager:getCommonValueById(289,100)/100);
	--end
	return result

end

--初始化显示英雄数据
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
	local gift = self.m_cell_data.gift or {}
	return gift
end

return M
