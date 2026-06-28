local M = class("CommonItemTipsPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonItemTipsPop"
M.m_size_type = 2

function M:onEnter()
	self.backgrount_panel = self:findGameObject("backgrount_panel")
	self.icon_rect = self:findGameObject("icon_rect")
	audio:SendEvtUI("Play_UI_Popup_3")
	self:refreshUI()
end

function M:refreshUI()
	local data = self.m_model.m_normal_data
	self:setText("name_text",data.name)
	local des_text = self:setTextByLanKey("des_text",data.story)
	local icon = GameUtil:createItemElementByData(data,false,false)
	icon.transform:SetParent(self.icon_rect.transform, false)
	UIUtil.setContentSizeFitterLayoutVertical(des_text.gameObject)
	local rt = UIUtil.findRectTransform(des_text.gameObject)
	self:setContentPosition(rt.rect.height)
end

function M:setContentPosition(des_height)
	if not IsNull(self.m_model.m_target_obj) then
		local trans = self.m_model.m_target_obj.transform
		local pos = self.backgrount_panel.transform.parent:InverseTransformPoint(trans.position)
		UIUtil.setContentSizeFitterLayoutVertical(self.backgrount_panel)
		local rt = UIUtil.findRectTransform(self.backgrount_panel)
		local bg_node_rect = rt.parent.rect
		if pos.x + rt.rect.width /2 > bg_node_rect.width/2 then
			pos.x = bg_node_rect.width/2 - rt.rect.width /2 - 10
		elseif pos.x - rt.rect.width /2 < -(bg_node_rect.width/2) then
			pos.x = - bg_node_rect.width/2 + rt.rect.width /2 + 10
		end
		local content_height = des_height + 120
		local width,height = self.m_rt.rect.width, self.m_rt.rect.height
		local min_y = - height*0.5 + content_height*0.5 + 10
		local max_y = height*0.5 - content_height*0.5 - 10
		pos.y = math.min(max_y, math.max(pos.y + content_height*0.5 + 50, min_y))
		self.backgrount_panel.transform.localPosition = pos
	end
end

return M