local M = class("LoadingView",LikeOO.OOPopBase)

M.m_uiName = "Loading/SmallLoading"
M.m_size_type = 2
M.m_sortOrder = 10009
M.m_sortOrderChange = false
M.m_cache_ui_flag = true

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()

end


return M