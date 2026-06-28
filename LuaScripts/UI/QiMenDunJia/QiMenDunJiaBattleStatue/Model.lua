local M = class("QiMenDunJiaBattleStatueModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_main_data = self.m_params.main_data or {}
	self.m_version = self.m_main_data.ver or 0
	self.m_cell_id = self.m_params.cell_id or 0
	self.m_buff_value = 0
	self.m_all_buff_value = 0
	self.m_explore_add_value = 0 --贡献值
	self:initBuffData()
	self:initAllBuffValue()
end

function M:getVersion()
	return self.m_version
end

function M:getCellID()
	return self.m_cell_id
end

function M:initBuffData()
	local cell_data = self.m_main_data.cells[tostring(self.m_cell_id)] or {}
	local massif_data = self:getMassifCfg(cell_data.massif_id or 0)
	self.m_buff_value = massif_data.buffid_show or 0
	self.m_explore_add_value = massif_data.explore_add or 0
end

function M:initAllBuffValue()
	self.m_all_buff_value = 0
	local buff_data
	for k, v in pairs(self.m_main_data.effect_buff or {}) do
		buff_data = self:getMassifBuffCfg(k)
		if buff_data then
			self.m_all_buff_value = self.m_all_buff_value + buff_data.buffid_show * v
		end
	end
end

function M:updateAllBuffData(buff_data)
	table.merge(self.m_main_data.effect_buff, buff_data or {})
	self:initAllBuffValue()
end

function M:getMassifCfg(massif_ID)
	massif_ID = massif_ID or 0
	local massif_tab = ConfigManager:getCfgByName("gve_massif")
	local massif_data = massif_tab[massif_ID] or {}
	return massif_data
end

function M:getMassifBuffCfg(buff_ID)
	buff_ID = tonumber(buff_ID) or 0
	local massif_tab = ConfigManager:getCfgByName("gve_massif")
	for k, v in pairs(massif_tab) do
		if v.buffid == buff_ID then
			return v
		end
	end
end

function M:updateStrengthData(health_value)
	self.m_main_data.health = health_value or 0
end

function M:updateExploreData(explore_value)
	self.m_main_data.explore_value = explore_value or 0
end

function M:getAllBuffValue()
	return self.m_all_buff_value
end

function M:getBuffValue()
	return self.m_buff_value
end

function M:getStrength()
	return self.m_main_data.health or 0
end

function M:getBattleInfo()
	local cell_data = self.m_main_data.cells[tostring(self.m_cell_id)] or {}
	return self:getMassifCfg(cell_data.massif_id or 0)
end

function M:getExploreAddValue()
	return self.m_explore_add_value
end

return M
