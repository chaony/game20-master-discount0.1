local M = class("BiographyView",LikeOO.OOPopBase)

M.m_uiName = "Biography/BiographyIndex"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "biography_str_001")
	self:setTextByLanKey("enter_btn_text", "biography_str_005")
	self.reward_slider = self:findSlider("reward_slider")
	self.biography_box_btn = self:findGameObject("biography_box_btn")
	self:refreshUI()
	UserDataManager:removeRedDotByKey("biography")
end

function M:refreshUI()
	self:setObjectVisible("last_btn", self.m_model.m_show_biography ~= 1)
	self:setObjectVisible("last_chapter_text", self.m_model.m_show_biography ~= 1)
	self:setObjectVisible("next_btn", self.m_model.m_show_biography ~= self.m_model.m_max_bio_id)
	self:setObjectVisible("next_chapter_text", self.m_model.m_show_biography ~= self.m_model.m_max_bio_id)
	local biography = ConfigManager:getCfgByName("biography")
	local biography_chapter = ConfigManager:getCfgByName("biography_chapter")
	local biography_cfg = biography[self.m_model.m_show_biography]
	self:setTextByLanKey("name_text", biography_cfg.name)
	self:setTextByLanKey("talk_text", biography_cfg.welcome)
	local chapter_count = #biography_cfg.group
	local done_chapter_count = self.m_model:finishChapterLength()
	self.reward_slider.value = done_chapter_count/chapter_count
	local open_day = self.m_model:chapterOpened()

	local enter_btn = self:findImage("enter_btn")
	if open_day then
		enter_btn.material = nil
	else
		local gray_img = self:findImage("gray_img")
		enter_btn.material = gray_img.material
	end
	
	local pos_tab = {}
	if chapter_count == 3 then
		self:setObjectVisible("line_1", false)
		self:setObjectVisible("line_2", true)
	elseif chapter_count == 4 then
		self:setObjectVisible("line_1", true)
		self:setObjectVisible("line_2", false)
	end
	
	if self.m_model:boxIsCanReceive() then
		self:setObjectVisible("UI_Bio_BaoXiang_001", true)
	else
		self:setObjectVisible("UI_Bio_BaoXiang_001", false)
	end
	
	for i=1, 4 do
		local v = biography_cfg.group[i]
		if v then
			local chapter_cfg = biography_chapter[v]
			local obj = self:findGameObject("chapter_bg_" .. i)
			UIUtil.setLocalPosition(obj.transform,chapter_cfg.pos[1], chapter_cfg.pos[2])
			self:setObjectVisible("chapter_bg_" .. i, true)
			local luaBehaviour = obj:GetComponent("LuaBehaviour")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"relation_text", chapter_cfg.relation)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text", chapter_cfg.name)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"select_img", self.m_model.m_chapter == v)
			local chapter_img = luaBehaviour:FindGameObject("chapter_img")
			GameUtil:updateResourcesImg(chapter_img, "Texture/biography/" .. chapter_cfg.icon)

			self:setObjectVisible("chapter_box_" .. i, true)
			local reward_box = self:findGameObject("chapter_box_" .. i)
			local box_luaBehaviour = reward_box:GetComponent("LuaBehaviour")
			local item = box_luaBehaviour:FindGameObject("ItemNode")
			local item_luaBehaviour = item:GetComponent("LuaBehaviour")
			GameUtil:updateItemElement(item,chapter_cfg.reward[1],true, true)
			if self.m_model:chapterIsDone(v) then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"mask_img", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"name_bg", false)

				local function reward_click(trans,data)
					self:updateMsg("reward_click", data)
				end
				if self.m_model:chapterRewardIsReceive(self.m_model.m_show_biography, v) then
					--local chapter_box_btn = box_luaBehaviour:FindButton("chapter_box_btn")
					--chapter_box_btn.onClick:RemoveAllListeners()
					LuaBehaviourUtil.setObjectVisible(box_luaBehaviour,"chapter_box_btn", false)
					LuaBehaviourUtil.setObjectVisible(item_luaBehaviour,"tips_img", true)
					LuaBehaviourUtil.setTextByLanKey(item_luaBehaviour,"tips_text", "new_str_0058")
				else
					LuaBehaviourUtil.setObjectVisible(box_luaBehaviour,"chapter_box_btn", true)
					UIUtil.setButtonClick(reward_box.transform, reward_click,{bio_id = self.m_model.m_show_biography, chapter_id = v},"chapter_box_btn",self.m_uiName)
					LuaBehaviourUtil.setObjectVisible(item_luaBehaviour,"select_image", true)
				end
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"mask_img", self.m_model.m_chapter ~= v)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_img", self.m_model.m_chapter ~= v)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"finish_img", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"name_bg", self.m_model.m_chapter == v)

				--local chapter_box_btn = box_luaBehaviour:FindButton("chapter_box_btn")
				--chapter_box_btn.onClick:RemoveAllListeners()
				LuaBehaviourUtil.setObjectVisible(box_luaBehaviour,"chapter_box_btn", false)
			end
			
		else
			self:setObjectVisible("chapter_bg_" .. i, false)
			self:setObjectVisible("chapter_box_" .. i, false)
		end
	end

	if self.m_model:biographyIsOpen(self.m_model.m_show_biography) then
		self:setObjectVisible("enter_btn", true)
		self:setObjectVisible("biography_lock_text", false)
	else
		self:setObjectVisible("enter_btn", false)
		self:setObjectVisible("biography_lock_text", true)
		for i,v in ipairs(biography or {}) do
			if v.next == self.m_model.m_show_biography then
				local name = Language:getTextByKey(v.name)
				self:setTextByLanKey("biography_lock_text", "biography_str_004", name)
				break
			end
		end
		
	end
end
	
return M