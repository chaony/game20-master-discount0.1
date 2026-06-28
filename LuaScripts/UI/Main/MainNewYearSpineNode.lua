--- 上阵
---@class MainNewYearSpineNode : OOUIbase
local M = class("MainNewYearSpineNode",LikeOO.OOUIbase)

M.m_uiName = "Main/MainNewYearSpineNode"
M.m_iphoneXAdapter = true

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	--self:setObjectVisible("idle_count_text", false)
end

function M:destroy()
	if self.m_new_year_node  then
		self.m_new_year_node:destroy()
		self.m_new_year_node = nil
	end
	M.super.destroy(self)
end

return M