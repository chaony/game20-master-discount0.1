local M = class("LiteratureRankView",LikeOO.OOPopBase)

M.m_uiName = "Activities/EnjoySpring/LiteratureRank"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "enjoySpring_str_0001")
	self:setTextByLanKey("tips_text", "enjoySpring_str_0018")
	self.item_cell = self:findGameObject("item_cell")
	self:refreshUI()
end

function M:refreshUI()
	for i,v in ipairs(self.m_model.enjoy_spring_force or {}) do
		local group_node = self:findGameObject("group_" .. i)
		local luaBehaviour = group_node:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"recommend_img", false)
		local icon = luaBehaviour:FindGameObject("group_icon_img")
		GameUtil:updateResourcesImg(icon,"Texture/EnjoySpring/" .. v.icon)

		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"text_1","enjoySpring_str_0002")
		local num = self.m_model:getGroupPeopleCount(i)
		LuaBehaviourUtil.setText(luaBehaviour, "num_text", tostring(num))
		local word = string.cutText(Language:getTextByKey(v.name))
		for k=1, 4 do
			LuaBehaviourUtil.setText(luaBehaviour,"name_" .. k, word[k] or "")
		end
		local item_content = luaBehaviour:FindGameObject("item_content")
		UIUtil.destroyAllChild(item_content.transform)
		for k,m in ipairs(v.reward or {}) do
			local item_cell = GameUtil:instanceObject(self.item_cell, item_content)
			local item = UIUtil.findTrans(item_cell.transform, "ItemNode")
			GameUtil:updateItemElement(item, m,true, true)
		end
		local group_btn = luaBehaviour:FindGameObject("group_btn")
		UIUtil.setButtonClick(group_btn.transform, function()
			self:updateMsg("group_btn", i)
		end, nil, nil, self.m_uiName)
	end
end

return M