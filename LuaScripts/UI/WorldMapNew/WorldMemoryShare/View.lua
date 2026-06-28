local M = class("WorldMemoryShareView",LikeOO.OOPopBase)

M.m_uiName = "WorldMapNew/WorldMapOldMemory/WorldMemoryShare"
M.m_iphoneXAdapter = true
M.m_size_type = 2
function M:onEnter()
	self:setTextByLanKey("close_title_text", "world_str_015")
	
	self:refreshUI()
end

function M:refreshUI()
	
end

function M:hideUI()
	self:setObjectVisible("CommonCloseNode", false)
	self:setObjectVisible("Node_UI", false)
end

function M:showUI()
	self:setObjectVisible("CommonCloseNode", true)
	self:setObjectVisible("Node_UI", true)
end

function M:destroy()
	M.super.destroy(self)
end

return M