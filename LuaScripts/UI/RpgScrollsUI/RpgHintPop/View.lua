local M = class("RpgHintPopView",LikeOO.OOPopBase)

M.m_uiName = "RpgScrollsUI/RpgHintPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true
function M:onEnter()
	self:setText("content_text", self.m_model.m_text)
	self:setText("cancle_text", self.m_model.m_cancel_text)
	self:setText("ok_text", self.m_model.m_ok_text)
	self:setText("common_title_text", Language:getTextByKey("new_str_0005"))
end




return M