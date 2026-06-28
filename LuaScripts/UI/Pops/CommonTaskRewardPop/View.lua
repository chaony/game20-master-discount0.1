local M = class("CommonTaskRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonTaskRewardPop"
M.m_size_type = 2

function M:onEnter()
	self.sound = audio:SendEvtUI('PLAY_UI_ITEM')
	self.reward_grid = self:findGameObject("reward_grid")
	self:setObjectVisible("quest_text", false)
	self:refreshUI()
	self:setTextByLanKey("next_chapter_btn_text", "new_str_0718")
	self:setTextByLanKey("close_chapter_btn_text", "new_str_0998")
	self:setObjectVisible("next_chapter_btn", self.m_model.m_show_next_chapter == true)
	self:setObjectVisible("close_chapter_btn", self.m_model.m_show_next_chapter == true)
	self.m_control:setOnceTimer(0.4,handler(self,self.fitPosition))
	self:lockTouch()
	self.m_control:setOnceTimer(0.6,function()
		self:unlockTouch()
	end)
end

function M:refreshUI()
	self:setTextByLanKey("quest_text", self.m_model:questCfgName())
	self.m_item = {}
	local rewards = self.m_model.m_quest_Data--RewardUtil:mergeRewardAndFormat()
	local num = #rewards
	for i = 1, num do
		local data = rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(self.reward_grid.transform, false)
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		UIUtil.setOpacity(item.transform, 0)
		if self.m_item[i] == nil then
			self.m_item[i] = {}
			self.m_item[i].obj = item
			self.m_item[i].type = data[1];
		end
	end
	self.num = num
end

function M:setAnimation()
	if self.animation.AnimationState:ToString() == "animation_1" then
		self.animation.AnimationState:SetAnimation(0, "animation_2", true)
	end
end

function M:fitPosition()
	if self.num > 4 then
		local rect = self.reward_grid.transform.rect
		UIUtil.setLocalPosition(self.reward_grid.transform, 0, -rect.height*0.5, 0)
	end
	self:setObjectVisible("quest_text", true)
	for i,v in ipairs(self.m_item) do
		UIUtil.setOpacity(v.obj.transform, 1)
	end
end

function M:destroy()
	audio:StopPlayingID(self.sound)
	self.sound = nil
    M.super.destroy(self)
end

function M:itemFlyAction()
    audio:SendEvtUI("PLAY_UI_GOLD")
	local delay = 0
	local target = self.m_model:getTarget()
    for k, v in pairs(self.m_item) do
		self:flyMove(v.obj, delay, target)
		delay = delay + 0.03
		if v.type == RewardUtil.REWARD_TYPE_KEYS.COIN or v.type  == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
			for i = 1, 8 do
				local item_obj = U3DUtil:Instantiate( v.obj );
				local random_y = Mathf.Random(10,200)
				local pos = v.obj.transform.localPosition + Vector3(4 * i, random_y, 0)
				self:flyMove(item_obj, delay, target, pos)
				delay = delay + 0.03
			end
		end
    end
end

function M:flyMove( obj, delay, target, pos )
	obj.transform:SetParent(static_rootControl.m_view.m_ui_obj.transform, true)
	obj.transform.localScale = Vector3(1,1,1)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
	if LuaBehaviour then
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "double_earn", false)  
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quality_img", false)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count_text_bg_img", false)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count_text", false)
	end
	if pos ~= nil then
		obj.transform.localPosition = pos;
	end
	local tweener = obj.transform:DOScale(0.4, 1)
	CS.wt.framework.TweenTool.Bezier(
			obj,
			target.transform,
			0.6,
			CS.wt.framework.BezierType.Bezier_Level2,
			delay,
			false,
			function()
				tweener:Kill()
				UIUtil.destroyObject(obj)
				static_rootControl:updateMsg("bag_action", nil, "parent")
			end
	)
end

return M