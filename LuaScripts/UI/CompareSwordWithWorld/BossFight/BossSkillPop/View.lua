local M = class("BossSkillPopView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/BossFight/BossSkillPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()

	self:refreshUI()
end

function M:refreshUI()
	local sk = self.m_model:getSkill()

	local sk_name = Language:getTextByKey(sk.name)
	self:setTextByLanKey("title_text", sk_name)

	self:setTextByLanKey("skill_text", self.m_model:getSkillBaseDesc(self.m_model.m_boss_idx))
	
	if self.m_model.m_click_transform then
		self:initSetPos()
	else
		UIUtil.setLocalPosition(contentNode.transform, 138 + (89 * self.m_model.m_skill_index - 1), -100, 0)
	end
	
	self:setObjectVisible("levelup_text", false)
	self:setObjectVisible("skill_improve", false)
end



function M:initSetPos()
	local contentNode = self:findGameObject("content_node")
	contentNode.transform.localPosition =  Vector3.New(10000,10000,0)
	local pos = self.content_node.transform.parent:InverseTransformPoint(self.m_model.m_click_transform.position)
	local content_w, content_h = 350, 20
	local width, height = self.m_rt.rect.width, self.m_rt.rect.height
	pos.y = math.max(math.min(pos.y, height * 0.5 - content_h * 0.5), -height * 0.5)
	pos.x = math.max(math.min(pos.x, width * 0.5 - content_w * 0.5), -width * 0.5 + content_w * 0.5)
	self.m_control:setOnceTimer(0.1, function ()
		local cont_rect = contentNode:GetComponent("RectTransform")
		if self.m_model.m_pivot then
			local d_pos = Vector3.New(pos.x, pos.y, pos.z)
			if self.m_model.m_pivot.x ~= 0.5 then
				if self.m_model.m_pivot.x == 0 then
					d_pos.x = pos.x + 175
				elseif self.m_model.m_pivot.x == 1 then
					d_pos.x = pos.x - 175
				end
			end
			if self.m_model.m_pivot.y ~= 0.5 then
				local height = cont_rect.rect.height
				if self.m_model.m_pivot.y == 0 then
					d_pos.y = pos.y - (height / 2)
				elseif self.m_model.m_pivot.y == 1 then
					d_pos.y = pos.y + (height / 2)
				end
			end
			contentNode.transform.localPosition = d_pos
		end
	end)
end

function M:onButtonClick(obj, name)
	M.super.onButtonClick(self, obj, name)
	if name == "select_btn" then
		local tips = Language:getTextByKey("anecdote_skill_tips", Language:getTextByKey(self.skillImproveGroup[self.skillImprove.cur_id].name))
		local params = {
			on_ok_call = function(msg)
				local function callfunc()
					--UserDataManager.skillImprove_data:setCurId(self.m_model.m_hero_id, self.skill_improve_id)
					self:setSkillImproveState(false)
				end
				self.m_model:getNetData("choose_improve", {hero_id = self.m_params.heroId, group_id = self.m_params.groupId}, callfunc)
			end,
			tow_close_btn = true,
			text = tips
		}
		self.m_control:openView("Pops.CommonPop", params, nil, true)
	end
end

function M:setSkillImproveState(select)
	if select then
		self:setTextByLanKey("select_text", "anecdote_selected")
		local btn = self:findButton("select_btn")
		btn.interactable = false
	else
		self:setTextByLanKey("select_text", "anecdote_select")
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M