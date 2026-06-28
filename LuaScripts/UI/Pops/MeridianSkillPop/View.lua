local M = class("MeridianSkillPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/MeridianSkillPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_click_transform then
		local contentNode = self:findGameObject("contentNode")
		local pos = contentNode.transform.parent:InverseTransformPoint(self.m_model.m_click_transform.position)
		local m_rt = contentNode:GetComponent("RectTransform")
		local content_w,content_h = 350, m_rt.rect.height+ 20
		local width,height = self.m_rt.rect.width, self.m_rt.rect.height
		local click_transform_h = self.m_model.m_click_transform.rect.height
		pos.y = pos.y + content_h*0.5 + click_transform_h*0.5
		pos.y = math.max(math.min(pos.y ,height*0.5 - content_h*0.5), - height*0.5)
        pos.x = math.max(math.min(pos.x ,width*0.5 - content_w*0.5), - width*0.5 + content_w*0.5)
		contentNode.transform.localPosition = pos
	end
	self:setTextByLanKey("skill_text", self.m_model.m_desc)
end

return M