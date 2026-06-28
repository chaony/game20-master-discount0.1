local M = class("WorldMapEncounterDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_event_data = self.m_params.event_data
	self.m_event_type = self.m_params.event_type
	self.m_finish_show = self.m_params.finish_show --是否是完成步的展示
	self.m_team_id = self.m_params.team_id
	self.m_x = self.m_params.x
	self.m_y = self.m_params.y
	local choise = self.m_event_data.choise or {}
	local choise_id = self.m_event_data.choise_id or {}
	self.m_select_drama_data = {}
	local encounter_cfg = ConfigManager:getCfgByName("encounter")
	for i, v in ipairs(choise) do
		local encounter_cfg_item = encounter_cfg[choise_id[i]]
		local finish_flag = false
		if encounter_cfg_item then
			finish_flag = encounter_cfg_item.ending_event == 1
		end
		table.insert(self.m_select_drama_data, {des = v, id = choise_id[i], finish_flag = finish_flag})
	end
end

function M:getSelectDramaData()
	return self.m_select_drama_data or {}
end

function M:selectIndexData(index)
	local data = self.m_select_drama_data[index]
	self.m_select_drama_data = {data}
end

function M:getEventData()
	local encounter_team_cfg = ConfigManager:getCfgByName("encounter_team")
	local map_event = UserDataManager:getEncounterMapEventData()
	local encounter_team_cfg_item = nil
	for k, v in pairs(map_event) do
		if v.event_id == self.m_event_data.id then
			local team_id = tonumber(k)
			UserDataManager:setTempData("map_battle_team_id", team_id)
			encounter_team_cfg_item = encounter_team_cfg[team_id]
			break
		end
	end
	if self.m_finish_show and self.m_team_id then
		encounter_team_cfg_item = encounter_team_cfg[self.m_team_id]
	end
	return self.m_event_data or {}, encounter_team_cfg_item or {}
end

return M
