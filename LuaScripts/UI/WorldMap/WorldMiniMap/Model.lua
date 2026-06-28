local M = class("WorldMiniMapModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()

	self:switchMap(self.m_params.map_id)
	self.map_open_cfg = ConfigManager:getCfgByName("worldmap_open")
	self.map_table = ConfigManager:getCfgByName("regional_map")
	self.maps = {}
	for k,v in pairs(self.map_open_cfg) do
		for k1,v1 in ipairs(v.map_id) do
			self.maps[v1] = v.stage_id
		end
	end
end

function M:switchMap(map_id)
	self.map_id = map_id
end

function M:getMapAreaCfg()
	local map_area_cfg = ConfigManager:getCfgByName("map_area")
	return map_area_cfg
end

function M:getEncounterMapEventData(chapter)
	local encounter_cfg = ConfigManager:getCfgByName("encounter")
	local map_event = UserDataManager:getEncounterMapEventData()
	local show_data = {}
	for k, v in pairs(map_event) do
		local map_event_cfg_item = encounter_cfg[v.event_id]
		if map_event_cfg_item.chapter == chapter then
			table.insert(show_data, {cfg = map_event_cfg_item, data = v})
		end
	end
	return show_data
end

function M:checkMapOpen(map_id)
	local map = self.map_table[map_id]
	if map ~= nil then
		return UserDataManager:getCurStage() >= map.stage_open, map.stage_open
	end
	return false, 0
end

return M
