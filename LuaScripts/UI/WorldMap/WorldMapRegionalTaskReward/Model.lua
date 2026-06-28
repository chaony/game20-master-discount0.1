local M = class("WorldMapRegionalTaskRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_map_id = self.m_params.map_id
	self.m_bg_image_name = "a_map_juqing_bg_1"
end

function M:getRegionalTaskDoneShowData()
	local regional_map_cfg = ConfigManager:getCfgByName("regional_map")
	local regional_task_done = UserDataManager:getRegionalTaskDoneData()
	local show_data = {}
	for k,v in pairs(regional_map_cfg) do
		if v.area == self.m_map_id then
			local regional_task_done_item = regional_task_done[tostring(self.m_map_id)] or {}
			local scenes = regional_task_done_item.scenes or {}
			local scene_data = scenes[tostring(k)] or {}
			table.insert(show_data, {id = k, cfg = v, data = scene_data})
			if v.map_id ~= 0 then
				self.m_bg_image_name = v.map_resource
			end
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.id < data2.id
	end)
	return show_data
end

function M:getTitleTextName()
	local map_area_cfg = ConfigManager:getCfgByName("map_area")
	local map_area_cfg_item = map_area_cfg[tonumber(self.m_map_id)] or {}
	return map_area_cfg_item.name
end

return M
