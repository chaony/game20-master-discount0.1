local M = class("WorldMapSelectModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("new_big_map_home")
end

function M:onEnter()
	self.m_big_map_data = self.m_data.big_map or {}
	self.m_new_big_map_data = self.m_data.new_big_map or {}
	self.m_map_id = self.m_big_map_data.first_scene
	self.m_scene_num = self.m_big_map_data.scene_num
	
	self.m_new_map_id = self.m_new_big_map_data.first_scene
	self.m_new_scene_num = self.m_new_big_map_data.scene_num
end

--获取支线任务
function M:getMapConfigById(id)
	if not id then return end
	local regional_map_cfg = ConfigManager:getCfgByName("regional_map")
	local map_cfg = regional_map_cfg[id] or {}
	return map_cfg
end

--获取支线任务
function M:getNewMapConfigById(id)
	if not id then return end
	local new_regional_map_cfg = ConfigManager:getCfgByName("new_regional_map")
	local map_cfg = new_regional_map_cfg[id] or {}
	return map_cfg
end


return M
