local M = class("WorldMapJournalModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("big_map_travel_log_index")
end

function M:onEnter()
	self.travel_log = self.m_data.travel_log
	self.show_gift = self.m_params.show_gift
	self.task_table = ConfigManager:getCfgByName("regional_task")
	self.map_table = ConfigManager:getCfgByName("regional_map")
end

function M:getTravelLog()
	local travel_data = {}
	for k,v in ipairs(self.travel_log) do
		if v.type == 1 then
			if SceneManager.curScene:checkMapOpen(v.scene_id) == true then
				table.insert(travel_data, v)
			end
		else
			table.insert(travel_data, v)	
		end
	end
	return travel_data
end

--获取任务根场景id
function M:getMotherMapId(id)
	if self.map_table[id] ~= nil then
		local mother_map_id = self.map_table[id].mother_map_id
		if mother_map_id > 0 then
			return self:getMotherMapId(mother_map_id)
		end
	end
	return id
end

function M:checkTaskDone(task_id)
	local task_data = self.task_table[task_id]
	local task_done = UserDataManager:getRegionalTaskDoneData()
	local cur_task_done = task_done[tostring(task_data.area)]
	local motherMapId = self:getMotherMapId(task_data.chapter)
	if cur_task_done ~= nil and cur_task_done.scenes[tostring(motherMapId)] ~= nil then
		for k,v in pairs(cur_task_done.scenes[tostring(motherMapId)].tasks) do
			if task_id == v and task_data.ending_event == 1 then
				return true
			end
		end
	end
	return false
end

return M
