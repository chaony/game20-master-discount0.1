local M = class("MapRoutePopModel", LikeOO.OODataBase)


function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.mother_map_id = self.m_params.mother_map_id
	self.cur_map_id = self.m_params.cur_map_id
	self.scene_lines = self.m_params.scene_lines
	self.map_table = ConfigManager:getCfgByName("regional_map")
end

function M:getMapName(id)
	return self.map_table[id].name
end

return M
 