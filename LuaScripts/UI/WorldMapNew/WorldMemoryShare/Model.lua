local M = class("WorldMemoryShareModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	
end

--获取支线任务
function M:getMapConfigById(id)
	if not id then return end
	local regional_map_cfg = ConfigManager:getCfgByName("regional_map")
	local map_cfg = regional_map_cfg[id] or {}
	return map_cfg
end

return M
