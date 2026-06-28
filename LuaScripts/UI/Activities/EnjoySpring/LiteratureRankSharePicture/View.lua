local M = class("LiteratureRankSharePictureView",LikeOO.OOPopBase)

M.m_uiName = "Activities/EnjoySpring/LiteratureRankSharePicture"
M.m_size_type = 2

function M:onEnter()
	self.m_control:openView("SharePicture")
end

return M