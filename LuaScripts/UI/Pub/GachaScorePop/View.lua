local M = class("GachaScorePopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/GachaScorePop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("text2", "Pub_str_0050")
	self:setTextByLanKey("recruit_btn_text", "new_str_0400")
	self:refresh()
end

function M:refresh()
	local bar = self:findSlider("bar")
	bar.value = self.m_model.m_score / self.m_model.m_score_consume
	self:setText("bar_value", self.m_model.m_score .. "/" .. self.m_model.m_score_consume)
	self:setTextByLanKey("text1", "Pub_str_0049", self.m_model.m_score_consume)
end

return M