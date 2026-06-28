local M = class("WorldMapEventsModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = nil
	self.m_open_task_id = self.m_params.task_id or 0
	self.regional_task_team_cfg = ConfigManager:getCfgByName("regional_task_team")
	self.regional_task_cfg = ConfigManager:getCfgByName("regional_task")
	self.article_opt_table = ConfigManager:getCfgByName("regional_article_option")

	self.task_team_data = {}
	for k,v in pairs(self.regional_task_team_cfg) do
		if self.task_team_data[v.map_id] == nil then
			self.task_team_data[v.map_id] = {}
		end
		table.insert(self.task_team_data[v.map_id], k)
	end
end

--获取进行中任务
function M:getTaskData()
	local map_event = UserDataManager:getTasksData()
	local show_data = {}
	for k, v in pairs(map_event) do
		local regional_task_cfg_item = self.regional_task_cfg[tonumber(k)]
		table.insert(show_data, {task_id = tonumber(k), task_team_id = regional_task_cfg_item.tasks_types, Photo_Resources = regional_task_cfg_item.Photo_Resources, status = v.status, done = v.done})
	end
	table.sort(show_data, function(a,b) return a.task_team_id < b.task_team_id end)
	return show_data
end

--获取已完成任务
function M:getTaskDoneData()
	local task_done = UserDataManager:getRegionalTaskDoneData()
	local cur_task_done = task_done[tostring(SceneManager.curScene.sceneId)]
	local task_team_done = {}
	for k1,v1 in pairs(cur_task_done.scenes) do
		--self.task_team_data[k1]
	end
	
	--local done = false
	--if cur_task_done.scenes[tostring(self.m_scene_id)] ~= nil then
	--	for k,v in pairs(cur_task_done.scenes[tostring(self.m_scene_id)].tasks) do
	--		if id == v then
	--			done = true
	--			break
	--		end
	--	end
	--end
	--local task_tab = ConfigManager:getCfgByName("regional_task")
	--return 	done, task_tab[tonumber(id)]
end

return M
