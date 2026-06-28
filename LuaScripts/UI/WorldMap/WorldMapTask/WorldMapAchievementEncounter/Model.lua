local M = class("WorldMapAchievementEncounterModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("big_map_encounter_quest_index")
end

function M:onEnter()
	self.m_open_tab_index = self.m_params.open_tab_index or 1
	self.m_sel_tab_index = nil
end

function M:getQuestEncounterData()
	local quest_encounter_group_cfg = ConfigManager:getCfgByName("quest_encounter_group")
	local quest_encounter_cfg = ConfigManager:getCfgByName("quest_encounter")
	local quests = self.m_data.quests or {}
	local group_quests = self.m_data.group_quests or {}
	
	local group_ids = {}
	for k,v in pairs(quests) do
		local key = tonumber(k)
		local cfg = quest_encounter_cfg[key]
		if cfg then
			local group = cfg.group
			if group_ids[group] == nil then
				group_ids[group] = {}
			end
			table.insert(group_ids[group], key)
		end
	end
	local show_data = {}
	for k,v in pairs(group_quests) do
		local group_id = tonumber(k)
		local group_cfg = quest_encounter_group_cfg[group_id]
		if group_cfg then
			local target_id = group_cfg.target_id
			local quest_encounter_ids = group_ids[target_id] or {}
			local items_data = {}
			for k1, v1 in pairs(quest_encounter_ids) do
				local cfg = quest_encounter_cfg[v1]
				local data = quests[tostring(v1)] or {}
				local value = data.value or 0
				local status = data.status or 0 -- 2为领过奖励 - 如果没有领取status没有
				local target_value = cfg.target_value
				if status == 2 then
					status = -1
				else
					if value >= target_value then -- 完成可领取
						status = 1
					end
				end
				table.insert(items_data, {id = v1, cfg = cfg, status = status, cur_progress = value, target_value = target_value})
			end
			table.insert(show_data, {items_data = items_data, group_cfg = group_cfg, group_id = group_id, cur_progress = v.value, target_value = group_cfg.target_value, status = v.status})
		end
	end
	table.sort(show_data, function(data1, data2) 
		return data1.group_id < data2.group_id
	end)
	for k,v in pairs(show_data) do
		table.sort(v.items_data, function(data1, data2)
			return data1.id < data2.id
		end)
	end
	return show_data
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	table.merge(self.m_data, data)
end

return M
