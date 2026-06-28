local M = class("LevelUpPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/LevelUpPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
	audio:SendEvtUI("Ui_LevelUp_Player")
end

function M:refreshUI()
	self:setTextByLanKey("lv_text","new_str_0215")
	self:setTextByLanKey("lvup_text","new_str_0216")
	self:setTextByLanKey("common_title_text","shareLv_str_0014")
	self:setText("lv_1_text", self.m_model.m_old_lv)
	self:setText("lv_2_text", self.m_model.m_lv)
	local itemParent =self:findGameObject("item_parent")
	self.m_item = {}
	local num = math.min(10,#self.m_model.m_rewards)
	for i = 1, num do
		local data = self.m_model.m_rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(itemParent.transform, false)
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		UIUtil.setOpacity(item.transform, 0)
		self.m_item[i] = item
	end
	self.m_control:setOnceTimer(0.5, function ()
		for k,v in pairs(self.m_item) do
			UIUtil.setOpacity(v.transform, 1)
		end
	end)
	-- local lv_spine = self:findGameObject("lv_spine")
	-- local animation = lv_spine:GetComponent("SkeletonGraphic")
	-- local function complete(msg)
	-- 	if animation.AnimationState:ToString() == "animation_1" then
	-- 		animation.AnimationState:SetAnimation(0, "animation_2", true)
	-- 	end
	-- end
	-- lv_spine:SetActive(true)
	-- self:addSpineComplete(animation.AnimationState,complete)
	-- animation.AnimationState:SetAnimation(0, "animation_1", false)
end



return M