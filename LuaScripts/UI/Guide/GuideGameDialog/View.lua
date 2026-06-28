local M = class("GuideGameDialogView", LikeOO.OOPopBase)

M.m_uiName = "Guide/GuideGameDialog"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	local order = self.m_model.m_guide.m_view.m_sortOrder + 99
	--Logger.log(self.m_sortOrder, "self.m_sortOrder ===")
	--Logger.log(order, "GuideDialog order ===")
	self.m_canvas.sortingOrder = order
	self:setTextByLanKey("skip_btn_text", "new_str_0346")
	self.m_highlight_node = self:findGameObject("highlight_node")
	self.m_highlight_node_follow_ui = self.m_highlight_node:GetComponent("FollowUI")

	if self.m_model.m_target_pos_list or self.m_model.m_target_trans_list then
		local highlight_nodes = self:findGameObject("highlight_nodes")
		self.m_guide_node = self:findGameObject("guide_node")
		self.m_hollowOutMask = self.m_guide_node:GetComponent("HollowOutMask")
		if self.m_model.m_target_pos_list then
			for i,v in ipairs(self.m_model.m_target_pos_list) do
				local highlight = U3DUtil:Instantiate(self.m_highlight_node);
				highlight.transform:SetParent(highlight_nodes.transform, false)
				self:setPositionByPos(highlight, v)
			end
		else
			for i,v in ipairs(self.m_model.m_target_trans_list) do
				local highlight = U3DUtil:Instantiate(self.m_highlight_node);
				highlight.transform:SetParent(highlight_nodes.transform, false)
				self:setPositionByTargetNode(highlight, v)
			end
		end
		self.finger_img = self:findGameObject("finger_img")
		self.m_highlight_node:SetActive(false)
		self.finger_img:SetActive(false)
	else
		local mask_clip_img = self:findGameObject("mask_clip_img")

		if self.m_model.m_target_pos == nil then
			local target_trans = self.m_model.m_target_trans
			local pos = target_trans.parent:TransformPoint(target_trans.localPosition) --世界坐标
			pos = self.m_highlight_node.transform.parent:InverseTransformPoint(pos) -- 相对坐标
			--self.m_highlight_node.transform.localPosition = pos

			self.m_guide_node = self:findGameObject("guide_node")
			self.m_hollowOutMask = self.m_guide_node:GetComponent("HollowOutMask")
			local rt = target_trans.gameObject:GetComponent("RectTransform")
			self.m_hollowOutMask:SetTarget(rt)
			local max = math.max(rt.rect.width, rt.rect.height)
			mask_clip_img:GetComponent("RectTransform").sizeDelta = Vector2.New(max, max)
		else
			local template_img = self:findGameObject("template_img")
			self.m_highlight_node.transform.position = self.m_model.m_target_pos
			local position = self.m_highlight_node.transform.localPosition
			position.z = 0
			self.m_highlight_node.transform.localPosition = position
			self.m_guide_node = self:findGameObject("guide_node")
			self.m_hollowOutMask = self.m_guide_node:GetComponent("HollowOutMask")
			local rt = template_img:GetComponent("RectTransform")
			self.m_hollowOutMask:SetTarget(rt)
			local max = math.max(rt.rect.width, rt.rect.height)
			mask_clip_img:GetComponent("RectTransform").sizeDelta = Vector2.New(max, max)
		end

		self.finger_img = self:findGameObject("finger_img")
		if UserDataManager.guide_data.m_finger_pos then
			self.finger_img.transform.localPosition = UserDataManager.guide_data.m_finger_pos
		end
	end
	
	self.m_hollowOutMask:SetTargetSwitch(true)
	if self.m_model.m_close_skip then
		self:setObjectVisible("skip_btn", false)
	end
	
	
	self:refreshUI()
end

function M:setPositionByPos(node, pos)
	local template_img = node.transform:Find("template_img")
	local mask_clip_img = node.transform:Find("mask_clip_img")
	node.transform.position = pos
	local position = node.transform.localPosition
	position.z = 0
	node.transform.localPosition = position
	local rt = template_img:GetComponent("RectTransform")
	self.m_hollowOutMask:addTargetToList(rt)
	local max = math.max(rt.rect.width, rt.rect.height)
	mask_clip_img:GetComponent("RectTransform").sizeDelta = Vector2.New(max, max)
end

function M:setPositionByTargetNode(node, target_node)
	local mask_clip_img = node.transform:Find("mask_clip_img")
	local target_trans = target_node.transform
	local pos = target_trans.parent:TransformPoint(target_trans.localPosition) --世界坐标
	pos = node.transform.parent:InverseTransformPoint(pos) -- 相对坐标
	node.transform.localPosition = pos
	local rt = target_trans.gameObject:GetComponent("RectTransform")
	self.m_hollowOutMask:addTargetToList(rt)
	local max = math.max(rt.rect.width, rt.rect.height)
	mask_clip_img:GetComponent("RectTransform").sizeDelta = Vector2.New(max, max)
end

function M:refreshUI()
	local hand_pos_x = 0
	local hand_pos_y = 0
	local guide_info = self.m_model.m_guide:getCurExcuteGuideInfo()
	if guide_info then
		local des = guide_info.des
		local hero_id = guide_info.hero_id
		self:setTextByLanKey("guide_text", tostring(des))
		self:setObjectVisible("guide_text_node", des~="")

		if guide_info.voice and guide_info.voice ~= "" then
			self.bank = guide_info.soundbank
			if self.bank and self.bank ~= "" then
				ResourceUtil:LoadBank(self.bank)
				audio:StopPlayingID(self.cur_cv)
				self.cur_cv = audio:SendEvtUI(guide_info.voice)
			end
		end

		local hero_cfg =  UserDataManager.hero_data:getHeroConfigByCid(guide_info.hero_id)
		local hero_spine = self:findGameObject("hero_spine")
		if hero_cfg then
			self:setImg("a_xs_head_" .. guide_info.hero_id, "main_ui", "head_img")
			self:setTextByLanKey("hero_name_text", hero_cfg.name)
			-- local sg = hero_spine:GetComponent("SkeletonGraphic")
			-- local skeleton_data = ResourceUtil:GetSk(hero_cfg.hero_spine, "rolespine_"..string.lower( hero_cfg.hero_spine ) )
			-- sg.skeletonDataAsset = skeleton_data
			-- sg:Initialize(true)
		else
			hero_spine:SetActive(false)
		end

		local des_pos = guide_info.des_pos
		if des_pos and next(des_pos) then
			local name_bg_img = self:findGameObject("name_bg_img")
			local guide_text_node = self:findGameObject("guide_text_node")
			-- if des_pos[1] == 2 then
			-- 	UIUtil.setLocalPosition(hero_spine, 176)
			-- 	UIUtil.setLocalPosition(name_bg_img, 174)
			-- else
			-- 	UIUtil.setLocalPosition(hero_spine, -176)
			-- 	UIUtil.setLocalPosition(name_bg_img, -174)
			-- end

			local offsetx = des_pos[2] or 0
			local offsety = des_pos[3] or 0
			UIUtil.setLocalPosition(guide_text_node, offsetx, offsety)
		end
		local hand_pos = guide_info.hand_pos
		if hand_pos then
			local figer_sp = self:findGameObject("figer_sp")
			hand_pos_x = hand_pos[1] or 0
			hand_pos_y = hand_pos[2] or 0
			local offsetx = hand_pos_x
			local offsety = hand_pos_y
			UIUtil.setLocalPosition(figer_sp, offsetx, offsety)
		end

		self:setObjectVisible("skip_btn", guide_info.skip_bt == 1)
	else
		self:setObjectVisible("guide_text_node", false)
	end

	if self.m_model.m_finger == 0 then
		self:setObjectVisible("figer_sp", false)
		self:setObjectVisible("figer2_sp", false)
	elseif self.m_model.m_finger == 1 then
		self:setObjectVisible("figer_sp", true)
		self:setObjectVisible("figer2_sp", false)
	elseif self.m_model.m_finger == 2 then
		self:setObjectVisible("figer_sp", false)
		self:setObjectVisible("figer2_sp", true)
	end
		
	if self.m_model.m_guideIsForce and self.m_model.m_eventType ~= 4 then
		self.m_hollowOutMask.enabled = true
		self:setObjectVisible("guide_node", self.m_model.m_maskType == 1)
		if self.m_model.m_maskType == 1 then
			self:setObjectVisible("guide_node", true)
		elseif self.m_model.m_maskType == 2 then
			self:setObjectVisible("guide_node", false)
		elseif self.m_model.m_maskType == 3 then
			self:setObjectVisible("guide_node", true)
			self.m_hollowOutMask.color = Color(0,0,0,0)
			self:setObjectVisible("mask_clip_img", false)
			self:setObjectVisible("mask_img", false)
		end
	else
		self.m_hollowOutMask.enabled = false
		self:setObjectVisible("guide_node", true)
		self:setObjectVisible("mask_clip_img", false)
		self:setObjectVisible("mask_img", false)
	end
	

	if self.m_model.m_eventType == 2 then
		self.m_hollowOutMask:SetTargetSwitch(false)
		self:setObjectVisible("close_btn", true)
		self:setObjectVisible("figer_sp", false)
	elseif self.m_model.m_eventType == 3 then
		self.m_hollowOutMask:SetTargetSwitch(false)
		self:setObjectVisible("close_btn", true)
	end

	if self.m_model.m_target_pos_list == nil  and self.m_model.m_target_trans_list == nil then
		--self.m_highlight_node:SetActive(false)
		--local positon = self.m_highlight_node.transform.localPosition
		--positon.x = positon.x + 10 + hand_pos_x
		--positon.y = positon.y - 45 + hand_pos_y
		--local sequence = Tweening.DOTween.Sequence()
		--sequence:Append(self.finger_img.transform:DOLocalMove(positon, 0.5))
		--sequence:OnComplete(function ()
		--	self.m_highlight_node:SetActive(true)
		--	self.finger_img:SetActive(false)
		--	if not IsNull(self.m_highlight_node_follow_ui) and not IsNull(self.m_model.m_target_trans) and self.m_model.m_target_pos == nil then
		--		self.m_highlight_node_follow_ui:SetTarget(self.m_model.m_target_trans)
		--	end
		--end)
		--sequence:SetAutoKill(true)
		--UserDataManager.guide_data.m_finger_pos = positon
		
	end
end

function M:onDestroy()
	if self.cur_cv then
		audio:StopPlayingID(self.cur_cv)
		self.cur_cv = nil
	end
	if self.bank then
		ResourceUtil:UnLoadBank(self.bank)
		self.bank = nil
	end
end

return M