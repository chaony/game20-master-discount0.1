local M = class("BigLoadingView",LikeOO.OOPopBase)

M.m_uiName = "Loading/BigLoading"
M.m_normal = false
M.m_sortOrder = 10010
M.m_size_type = 2
M.m_sortOrderChange = false

function M:onEnter()
	self:setTextByLanKey("tips_text", "new_str_0445")
	self.progress_slider = self:findSlider("progress_slider")
	self.progress_slider.gameObject:SetActive(false)
	self:refreshUI()
end

function M:refreshUI()

end


return M