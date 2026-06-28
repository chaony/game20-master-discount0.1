local M = class("GuJianQiTanMazeEncounterDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	----- event_data = sample_data, cell_id = data.id, cell_data = data, event_id = event_id
	self.m_data = self.m_params.cell_data;
	self.m_event_data = self.m_params.event_data
	self.m_team_id = self.m_params.cell_data.type	
	self.m_cell_id = self.m_params.cell_id
	self.m_index = 0;
	self.m_event_id = self.m_params.event_id
	self.m_callBack = self.m_params.callBack
	--self.m_call_back = self.m_params.callBack;
	local choice = string.split(self.m_event_data.choice,",") or {}
	local choice_id = self.m_event_data.choice_id or {}
	self.m_select_drama_data = {}
	local encounter_cfg = ConfigManager:getCfgByName("sword_akuma_event")
	for i, v in pairs(choice) do
		table.insert(self.m_select_drama_data, {des = v, id = choice_id[i], finish_flag = true})
	end
end

function M:getSelectDramaData()
	return self.m_select_drama_data or {}
end

function M:selectIndexData(index)
	local data = self.m_select_drama_data[index]
	self.m_select_drama_data = {data}
end

function M:getTeamData()
	local encounter_team_cfg = ConfigManager:getCfgByName("sword_akuma_element")
	local encounter_team_cfg_item = encounter_team_cfg[self.m_team_id]
	return encounter_team_cfg_item;
end

function M:getEventData()
	return self.m_event_data;
end

function M:getEncounterData()
	local encounter_cfg = ConfigManager:getCfgByName("sword_akuma_event")
	local encounter_cfg_item = encounter_cfg[self.m_id]
	encounter_cfg_item.id = self.m_id;
	return encounter_cfg_item
end

return M
