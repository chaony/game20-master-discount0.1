local M = class("MazeStageEncounterDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.cell_data;
	self.m_event_data = self.m_params.event_data
	self.m_team_id = self.m_params.team_id
	self.m_cell_id = self.m_params.cell_id
	self.m_index = 0;
	self.m_call_back = self.m_params.callBack;
	local choice = self.m_event_data.choice or {}
	local choice_id = self.m_event_data.choice_id or {}
	self.m_select_drama_data = {}
	local encounter_cfg = ConfigManager:getCfgByName("maze_encounter")
	for i, v in ipairs(choice) do
		local encounter_cfg_item = encounter_cfg[choice_id[i]]
		local finish_flag = false
		if encounter_cfg_item then
			finish_flag = encounter_cfg_item.ending_event == 1
		end
		table.insert(self.m_select_drama_data, {des = v, id = choice_id[i], finish_flag = finish_flag})
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
	local encounter_team_cfg = ConfigManager:getCfgByName("maze_encounter_team")
	local encounter_team_cfg_item = encounter_team_cfg[self.m_team_id]
	return encounter_team_cfg_item;
end

function M:getEventData()
	return self.m_event_data;
end

function M:getEncounterData()
	local encounter_cfg = ConfigManager:getCfgByName("maze_encounter")
	local encounter_cfg_item = encounter_cfg[self.m_id]
	encounter_cfg_item.id = self.m_id;
	return encounter_cfg_item
end

return M
