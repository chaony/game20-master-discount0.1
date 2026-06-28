local M = class("ArtifactDescPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "HeroInfo/ArtifactDescPop"

function M:onEnter()
	self:setTextByLanKey("common_title_text", "神器传说")
	self:setTextByLanKey("des_text", self.m_model.m_desc)
end

return M