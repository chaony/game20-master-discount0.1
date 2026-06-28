local M = class("HuntTreasuresLogPop", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("mining_battle_info")
end

function M:onEnter()
	self.m_battle_log = self.m_data and self.m_data.battle_logs or {}
	self.m_mining_region_config = ConfigManager:getCfgByName("mining_region") or {}
	self.m_mining_location_config = ConfigManager:getCfgByName("mining_location") or {}
	
end

function M:getBattleLogId(index)
	local battle_log_id = self.m_battle_log[index].battle_id or 0
	return battle_log_id
end

function M:getRidAndLid(index)
	local oid = self.m_battle_log[index].oid or 0
	local region_id =  math.modf(oid / 10000)
	local location_id = math.modf((oid - region_id * 10000) / 100)
	return region_id, location_id
end

function M:getMineName(index)
	local region_id, location_id = self:getRidAndLid(index)
	local name = self.m_mining_location_config[region_id][location_id] and self.m_mining_location_config[region_id][location_id].name or ""
	local produce_add = self.m_mining_location_config[region_id][location_id] and self.m_mining_location_config[region_id][location_id].produce or 1
	return name, produce_add
end

return M
