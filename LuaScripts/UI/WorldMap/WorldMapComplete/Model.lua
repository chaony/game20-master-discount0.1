local M = class("WorldMapCompleteModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self:select_map(SceneManager.curScene.sceneId)
	self.map_area_cfg = ConfigManager:getCfgByName("map_area")
	self.map_open_cfg = ConfigManager:getCfgByName("worldmap_open")
	self.map_table = ConfigManager:getCfgByName("regional_map")
	self.maps = {}
	for k,v in pairs(self.map_open_cfg) do
		for k1,v1 in ipairs(v.map_id) do
			self.maps[v1] = v.stage_id
		end
	end
end

function M:select_map(id)
	self.select_id = id
end

function M:getAreaData()
	local show_data = {}
	for k,v in pairs(self.map_area_cfg) do
		if (self.map_area_cfg[k].season and self.map_area_cfg[k].season <= UserDataManager.m_season_data.season) or k == 91 then --地图都进来了，至少开一个地图吧
			table.insert(show_data, {mapId = k, mapName = v.name})
		end
	end
	table.sort(show_data, function(a,b) return a.mapId < b.mapId end)
	return show_data
end

function M:checkAreaOpen(id)
	local area_cfg = self.map_area_cfg[id]
	if area_cfg ~= nil then
		return UserDataManager:getCurStage() > area_cfg.unlock
	end
	return false
end

function M:checkMapOpen(map_id)
	local map = self.map_table[map_id]
	if map ~= nil then
		return UserDataManager:getCurStage() >= map.stage_open, map.stage_open
	end
	return false, 0
end

function M:getOpenCondition(id)
	local area_cfg = self.map_area_cfg[id]
	local condition = area_cfg.unlock
	local open_flag, tips_str = GameUtil:getStageUnlock(condition)
	return condition, tips_str
end

function M:getMapCpd(area_id, scene_id)
	local regional_task_done = UserDataManager:getRegionalTaskDoneData()
	local scene_line = UserDataManager:getSceneLineData()
	local cpd = 0 --百分比进度
	local status = 0 -- 0：未完成，1：可领取，2：已领取
	local area = regional_task_done[tostring(area_id)]
	local scene_line_area = scene_line[tostring(area_id)]
	local map_count = 0
	if area ~= nil then
		local scene = area.scenes[tostring(scene_id)]
		if scene ~= nil then
			cpd = scene.cpd
			status = scene.status or 0
		end
	end
	if scene_line_area ~= nil then
		local scene_line_map = scene_line_area[tostring(scene_id)]
		if scene_line_map ~= nil then
			map_count = #scene_line_map
		end
	end
	return map_count, status
end

function M:checkTaskTeam(id)
	local task_team_cfg = ConfigManager:getCfgByName("regional_task_team")
	return task_team_cfg[id]
end

return M
