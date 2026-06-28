local M = class("FiveLinesDeffDetailModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cell_data = self.m_params.data
	self.m_index = self.m_params.index;
	--快速战斗使用
	self.m_show_hero_data = self:initShowHeroData()
end

--是否可以快速战斗
function M:canQuickBattle()
	--local result = false;
	----迷宫阵容总战力
	--result = self.m_total_combat <  self.m_heros_combat * (ConfigManager:getCommonValueById(289,100)/100);
	--return result
	return false;
end

--初始化显示英雄数据
function M:initShowHeroData()
	local show_data = {}
	local heros = self.m_cell_data.heros or {}
	local def_team = self.m_cell_data.def_team or {}
	if _G.next(def_team) ~= nil then
		for k,v in ipairs(def_team) do
			local hero_data = heros[v]
			if hero_data then
				local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
				data.quality = hero_data.evo
				data.card_id = k
				data.hero_data = hero_data
				data.dyns = {}
				table.insert(show_data, data)
			end
		end
	else
		for k,v in pairs(heros) do
			local hero_data = v
			if hero_data then
				local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
				data.quality = hero_data.evo
				data.card_id = k
				data.hero_data = hero_data
				data.dyns = {}
				table.insert(show_data, data)
			end
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
