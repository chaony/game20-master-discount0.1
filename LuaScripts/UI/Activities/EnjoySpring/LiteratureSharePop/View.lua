local M = class("LiteratureSharePopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/EnjoySpring/LiteratureSharePop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "castingSword_str_0016")
end

function M:refreshUI()

end

return M