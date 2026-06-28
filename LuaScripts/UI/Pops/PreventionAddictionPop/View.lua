local M = class("PreventionAddictionPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/PreventionAddictionPop"
M.m_normal = false
M.m_sortOrder = 10012
M.m_size_type = 2
M.m_sortOrderChange = false

function M:onEnter()	
	self:setText("msg_text", self.m_model.m_text)
	self:setText("cancle_text", self.m_model.m_cancel_text)
	self:setText("ok_text", self.m_model.m_ok_text)
	self:setText("common_title_text", self.m_model.m_title)
	self.m_big_close_btn = self:findButton("big_close_btn")
	if self.m_model.m_no_close_btn then
		self.m_big_close_btn.enabled = false
		self:setObjectVisible("cancle_btn", false)
		self:setObjectVisible("close_btn", false)
		self.m_ok_btn = self:findButton("ok_btn")
		UIUtil.setLocalPosition(self.m_ok_btn.transform, 0)
	else
		self.m_ok_btn = self:findButton("ok_btn")
		
		self:setObjectVisible("close_btn", true)
		if self.m_model.m_tow_close_btn then
			UIUtil.setLocalPosition(self.m_ok_btn.transform, 110)
			self:setObjectVisible("cancle_btn", true)
		else
			UIUtil.setLocalPosition(self.m_ok_btn.transform, 0)
			self:setObjectVisible("cancle_btn", false)
		end
	end
	if self.m_model.m_cost then
		self:setObjectVisible("own_node", true)
		self:setText("own_title_text", Language:getTextByKey("new_str_0035"))
		local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
		local user_num = GameUtil:formatValueToString(data.user_num)
		self:setText("own_num_text", user_num)
		self:setImg(data.icon_name, data.atlas_name or "item_icon", "own_icon")
	else
		self:setObjectVisible("own_node", false)
	end
	self:refreshUI()
end

function M:refreshUI()

end


return M