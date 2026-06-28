local M = class("WorldMapSelectView",LikeOO.OOPopBase)

M.m_uiName = "WorldMapNew/WorldMapOldMemory/WorldSelect"
M.m_iphoneXAdapter = true
M.m_size_type = 2
function M:onEnter()
	self:setTextByLanKey("close_title_text", "world_str_007")
	self:setTextByLanKey("jianghu_title", "world_str_014")
	self:setTextByLanKey("world_memory_title", "world_str_015")
	
	self:refreshUI()
end

function M:refreshUI()
	local map_cfg = self.m_model:getMapConfigById(self.m_model.m_map_id) or {}
	self:setTextByLanKey("jianghu_progress_des", "world_str_016",tostring(map_cfg.name))
	self:setTextByLanKey("jianghu_progress", "world_str_017",self.m_model.m_scene_num,tostring(map_cfg.scene))
	
	local new_map_cfg = self.m_model:getNewMapConfigById(self.m_model.m_new_map_id) or {}
	self:setTextByLanKey("memory_progress_des", "world_str_016",tostring(new_map_cfg.name))
	self:setTextByLanKey("memory_progress", "world_str_017",self.m_model.m_new_scene_num,tostring(new_map_cfg.scene))
end

function M:destroy()
	M.super.destroy(self)
end

return M