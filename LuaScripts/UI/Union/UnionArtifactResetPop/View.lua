local M = class("UnionArtifactResetPopView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionArtifactResetPop"
M.m_size_type = 2

function M:onEnter()	
	self:setText("msg_text", self.m_model.m_text)
	self:setText("cancle_text", self.m_model.m_cancel_text)
	self:setText("common_title_text", self.m_model.m_title)
	if self.m_model.m_cost and self.m_model.m_return_lvup_cost then
		self:setObjectVisible("own_node", true)
		self:setText("own_title_text", Language:getTextByKey("union_str_0020"))
		Logger.log(self.m_model.m_return_lvup_cost,"self.m_model.m_return_lvup_cost-->")
		local return_data = RewardUtil:getProcessRewardData(self.m_model.m_return_lvup_cost)
		local user_num = GameUtil:formatValueToString(return_data.data_num)
		self:setText("own_num_text", user_num)
		self:setImg(return_data.icon_name, return_data.atlas_name or "item_icon", "own_icon")

		local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
		self:setText("ok_text", data.data_num)
	else
		self:setObjectVisible("own_node", false)
	end
	self:refreshUI()
end

function M:refreshUI()

end


return M