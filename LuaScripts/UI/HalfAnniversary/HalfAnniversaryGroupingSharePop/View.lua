local M = class("HalfAnniversaryGroupingSharePopView",LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryGroupingSharePop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "castingSword_str_0016")
end

function M:refreshUI()

end

return M