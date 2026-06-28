---@class MazeStageRelicFormationShowModel:OODataBase
local M = class("MazeStageRelicFormationShowModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:initData(self.m_params.data)
	self.tips_text = self.m_params.tips_text or "new_str_0162"
	self.common_title_text = self.m_params.common_title_text or "new_str_0177"
	self.m_team_key = self.m_params.team_key or "maze"
	self.m_open_type = self.m_params.open_type or ""
end

function M:initData(data)
	self.m_data = data or self.m_data
	self:initHeirloomData()
end

function M:initHeirloomData()
	local show_data = {}
	local heirlooms = self.m_data.heirlooms or {}
	local heirloom = ConfigManager:getCfgByName("heirloom")
	for k,v in pairs(heirlooms) do
		local cfg = heirloom[v]
		if cfg then
			table.insert(show_data, {id = v, cfg = cfg})
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.quality > data2.cfg.quality
	end)
	self.m_heirlooms_data = show_data
end

function M:getHeirloomData()
	return self.m_heirlooms_data or {}
end

function M:getHeirloomNum()
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomNum(heirlooms)
end

-- 遗物战斗力加成计算
function M:getHeirloomCombatAddRatio()
	local team = UserDataManager.hero_data:getTeamByKey(self.m_team_key) or {}
	local assist_heros = self.m_data.assist_heros or {} --雇佣的英雄
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomCombatAddRatio(team, assist_heros, heirlooms)
end

return M
