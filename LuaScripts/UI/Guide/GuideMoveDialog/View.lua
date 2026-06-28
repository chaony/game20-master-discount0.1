local M = class("GuideMoveDialogView", LikeOO.OOPopBase)

M.m_uiName = "Guide/GuideMoveDialog"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("skip_btn_text", "new_str_0346")
	self.m_highlight_node = self:findGameObject("highlight_node")

	self.m_model.m_start_pos.z = 0
	local RectTransform = self.m_ui_obj:GetComponent("RectTransform")
	self.m_highlight_node.transform.position = self.m_model.m_start_pos
	local position = self.m_highlight_node.transform.localPosition
	position.z = 0

	self.m_highlight_node.transform.localPosition = position

	self.m_guide_node = self:findGameObject("guide_node")
	self.m_hollowOutMask = self.m_guide_node:GetComponent("HollowOutMask")
	self.figer_sp = self:findGameObject("figer_sp")

	self:refreshUI()
end

function M:refreshUI()
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
		if guide_info.target[2] == 5 then
			local sk_anim = self.figer_sp:GetComponent("SkeletonGraphic")
			sk_anim.AnimationState:SetAnimation(0, "animation_3", true)
		end
	else
		self:setObjectVisible("guide_text_node", false)
	end
	if self.m_model.m_guideIsForce then
		self.m_hollowOutMask.enabled = true
		self:setObjectVisible("guide_node", self.m_model.m_maskType == 1)
	else
		self.m_hollowOutMask.enabled = false
		self:setObjectVisible("guide_node", true)
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