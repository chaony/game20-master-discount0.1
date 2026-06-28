local M = class("SkillImprovePopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/SkillImprovePop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	local skill = self.m_model:getSkillById()
	local contentNode = self:findRectTransform("contentNode")

	self:setTextByLanKey("skill_name", skill.name)
	self:setTextByLanKey("des_text", skill.des)
	self:setImg("a_ui_currency_jineng_linshi", "hero_ui", "skillIcon")

	if self.m_model.m_click_transform then
		local click_pos = self.m_model.m_click_transform.position
		contentNode.position = click_pos
		local pos = contentNode.anchoredPosition
		pos.x = pos.x - 200
		contentNode.anchoredPosition = pos
	end
end

return M