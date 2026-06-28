local M = class("HalfAnniversaryGroupingSharePicturePictureView",LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryGroupingSharePicture"
M.m_size_type = 2

function M:onEnter()
	self.m_control:openView("SharePicture")
end

return M