local M = class("DemonstrateSceneView",LikeOO.OOSceneBase)

M.m_uiName = "Demonstrate/Demonstrate"
M.m_size_type = 1

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()

end


return M