local M = class("TransitionPageView",LikeOO.OOPopBase)

M.m_uiName = "Pops/TransitionPage"

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	
end

return M