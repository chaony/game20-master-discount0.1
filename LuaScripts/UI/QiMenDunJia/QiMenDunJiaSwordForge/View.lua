local M = class("QiMenDunJiaSwordForgeView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaSwordForge"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_loopscroll_view_cell_cache = {}
	self:setTextByLanKey("close_title_text", "qi_men_dun_jia_str_019")
	self:setTextByLanKey("level_up_text", "new_str_0407")
	self:setTextByLanKey("sword_reset_title", "sword_reset_text")
	
	--法宝动画
	local cur_relics_data = self.m_model:getCurrentRelicsData()
	if cur_relics_data then
		local effect_front =self:findGameObject("effect_front")
		local effect_name = cur_relics_data.cfg.Special
		local fx_ui_effect = ResourceUtil:GetUIEffectItem("MagicWeapon/" .. effect_name .. "_001")
		if not IsNull(fx_ui_effect) then
			fx_ui_effect.transform:SetParent(effect_front.transform, false)
		end
	end
	
	self:refreshUI()
end

function M:refreshUI()
	self:updateRelicsProgressLoopScroll()
	self:updateRelicsProgressBar()
	self:updateRelicsProgressLoopScrollStatus(true)
end

function M:updateRelicsProgressLoopScroll()
	local data = self.m_model:getRelicsData()
	if self.m_loopscroll_view_cache == nil then
		local loopscroll = self:findGameObject("left_slider_loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				if self.m_loopscroll_view_cell_cache[tostring(cell_object)] == nil then
					self.m_loopscroll_view_cell_cache[tostring(cell_object)] = cell_object
				end
				self:updateRelicsProgressLoopScrollCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				--设置选中标识
				for k, v in pairs(self.m_loopscroll_view_cell_cache) do
					local transform = v.transform
					local luaBehaviour = UIUtil.findLuaBehaviour(transform)
					if k == tostring(cell_object) then
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img_1", true)
					else
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img_1", false)
					end
				end
				self:updateMsg("box_click", cell_data)
			end
		}
		self.m_loopscroll_view_cache = LoopScrollViewUtil.new(params)
	else
		self.m_loopscroll_view_cache:reloadData(data)
	end
end

function M:updateRelicsProgressLoopScrollCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)

	local score_text = UIUtil.setText(transform, tostring(cell_data.lv), "score_text")
	local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
	score_text.color = cell_data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
	local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
	local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
	local box_img = luaBehaviour:FindImage("box_img")
	LuaBehaviourUtil.setImg(luaBehaviour, "box_img", cell_data.cfg.icon, "mystic_ui")
	
	--box_img:SetNativeSize()
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", true)
	if box_effect ~= nil then
		box_effect.gameObject:SetActive(false)
	end
	if box_effect2 ~= nil then
		box_effect2.gameObject:SetActive(false)
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", cell_data.status == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", cell_data.status == 1)
	if cell_data.status == 1 then
		if box_effect ~= nil then
			box_effect.gameObject:SetActive(true)
		end
		if box_effect2 ~= nil then
			box_effect2.gameObject:SetActive(true)
		end
	end

	--特殊里程碑标记
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MagicWeapon_ShiYong_001", cell_data.cfg.special_level == "1")
	
	--选中标识
	local selected_cell_data = self.m_model:getSelectedCellData()
	if selected_cell_data and selected_cell_data.id then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img_1", selected_cell_data.id == cell_data.id)
	end
	
	--当前等级标识
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "current_lev_bg", self.m_model:getRelicsLevel() == cell_data.lv)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "current_lev_flag", self.m_model:getRelicsLevel() == cell_data.lv)
end

--设置选中cell为当前等级
function M:updateRelicsProgressLoopScrollStatus(init_flag)
	if self.m_loopscroll_view_cache then
		local select_index = self.m_model:getRelicsLevel()
		self.m_loopscroll_view_cache:moveToCellIndex(select_index)
		self.m_loopscroll_view_cache:itemClick(nil, "QiMenDunJiaSwordForgeBox", select_index)
		if init_flag == false then
			self.m_control:setOnceTimer(0.01, function()
				self.m_loopscroll_view_cache:setHorizontalNormalizedPosition(self.m_model:getRelicsProgressLoopScrollPosition())
			end)
		end
	end
end

function M:getRelicsProgressLoopScrollPosition()
	return self.m_loopscroll_view_cache:getHorizontalNormalizedPosition()
end

function M:updateRelicsProgressBar()
	local box_node = self:findGameObject("box_node")
	local box_node_trans = box_node.transform
	local box_node_trans_rec = UIUtil.findRectTransform(box_node)
	local explore_slider = self:findSlider("left_progress_slider")
	UIUtil.destroyAllChild(box_node_trans)
	local show_data, cur_num = self.m_model:getRelicsData()
	local width = box_node_trans_rec.rect.width
	local max_num = 0
	local box_num = #show_data
	if show_data[box_num] then
		max_num = show_data[box_num].lv + 1 or 0
	end
	max_num = max_num > 0 and max_num or 100
	explore_slider.value = cur_num/max_num
end

function M:moveRelicsProgressLoopScrollPage(off_index)
	self.m_loopscroll_view_cache:moveHorizontalPage(off_index)
end

function M:updateRelicsInfo(relics_data)
	self.m_model:setSelectedCellData(relics_data)
	local is_select_current_level =  self.m_model:isSelectCurrentLevel()
	
	local skill_cfg
	if relics_data then
		skill_cfg = self.m_model:getSkillDataById(relics_data.cfg.skill_id)
	end
	if skill_cfg then
		self:setObjectVisible("right_node", true)
		self:setObjectVisible("left_sword_icon", true)
		local name_img = self:findImage("sword_name_img")
		GameUtil:updateResourcesImg(name_img, "Texture/zh_cn/".. relics_data.cfg.name)
		self:setTextByLanKey("wea_lv", "weapon_str_0009", relics_data.lv)
		self:setTextByLanKey("sword_des_content", relics_data.cfg.des)
		for i = 1, 3 do
			if relics_data.cfg.att[i] then
				local cur_atr_data = relics_data.cfg.att[i]
				local atr_key = GameUtil:getAttrsKey(cur_atr_data[1])
				local atr_name = GameUtil:getAttrsName(atr_key)
				local cur_num = cur_atr_data[2] or 0
				if GameUtil:canPerAttrTransition(atr_key) == true then
					cur_num = cur_num * 100
				end
				self:setTextByLanKey("attr_name" .. i, atr_name)
				self:setTextByLanKey("attr_num" .. i, cur_num .. "%")
			end
		end
		if is_select_current_level then
			local cost_data = RewardUtil:getProcessRewardData(relics_data.cfg.cost[1])
			if cost_data then
				local user_num = self.m_model:getRelicsExpCount()
				self:setImg(cost_data.icon_name, cost_data.atlas_name, "cost_img")
				local cost_text = self:setTextByLanKey("cost_num", user_num .. "/" .. cost_data.data_num)
				if user_num >= cost_data.data_num then
					cost_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
				else
					cost_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
				end
				if self.m_model:getRelicsExpCount() < self.m_model:getCurrentLevelRelicsCost() or self.m_model:isRelectMaxLevel() then --帮会币小于当前等级升级花销，或者升级到最大级
					local btn = self:setImg("a_ui_currency_btn_middle_4", "coach_ui", "level_up_btn")
					UIUtil.setOutlineExEffectColor(btn.transform,"level_up_btn", Color.New(90/255,90/255,90/255,70/255),1)
				else
					local btn = self:setImg("a_ui_currency_btn_middle_2", "coach_ui", "level_up_btn")
					UIUtil.setOutlineExEffectColor(btn.transform,"level_up_btn", Color.New(155/255,80/255,7/255,70/255),1)
				end
			end
				
		end
		self:setTextByLanKey("wea_skill_text", skill_cfg.name)
		self:setTextByLanKey("skill_lv", relics_data.lv or 1)
		self:setImg(skill_cfg.icon, "skill_icon","skill_icon")
		self:setTextByLanKey("skill_des_text",  skill_cfg.des)
	else
		self:setObjectVisible("right_node", false)
		self:setObjectVisible("left_sword_icon", false)
	end
	
	--使用，升级；只有选中当前等级时才展示
	local is_max_level = self.m_model:isRelectMaxLevel()
	self:setObjectVisible("use_btn_obj", is_select_current_level)
	self:setObjectVisible("level_up_btn_obj", is_select_current_level and is_max_level == false)
	if is_select_current_level then
		--使用按钮
		--if self.m_model:isRelicsFunctionOpen() == false then --法宝共功能未开启
		--	local btn = self:setImg("a_ui_currency_btn_middle_4", "coach_ui", "use_btn")
		--	self:setTextByLanKey("use_text", "new_str_0048")
		--	UIUtil.setOutlineExEffectColor(btn.transform,"use_text", Color.New(90/255,90/255,90/255,70/255),1)
		--else
		--	if self.m_model:isCurrentRelicsAvailableToUse() == false then --此位置上已经使用此类型法宝，就不能再使用了
		--		local btn = self:setImg("a_ui_currency_btn_middle_4", "coach_ui", "use_btn")
		--		self:setTextByLanKey("use_text", "weapon_str_0011")
		--		UIUtil.setOutlineExEffectColor(btn.transform,"use_text", Color.New(90/255,90/255,90/255,70/255),1)
		--	else
		--		local btn = self:setImg("a_ui_currency_btn_middle_3", "coach_ui", "use_btn")
		--		self:setTextByLanKey("use_text", "hunt_treasure_str_023")
		--		UIUtil.setOutlineExEffectColor(btn.transform,"use_text", Color.New(155/255,80/255,7/255,70/255),1)
		--	endss
		--end
		--改为前往
		if self.m_model:isRelicsFunctionOpen() == true then --法宝共功能已经开启
			self:setTextByLanKey("use_text", "qi_men_dun_jia_str_036")
			if self.m_model:getShareLv() == true then
				self:setImg("a_ui_currency_btn_middle_3", "coach_ui", "use_btn")
			else
				self:setImg("a_ui_currency_btn_middle_4", "coach_ui", "use_btn")
			end
		end
		--升级按钮
		if self.m_model:getRelicsExpCount() < self.m_model:getCurrentLevelRelicsCost() or is_max_level then --帮会币小于当前等级升级花销，或者升级到最大级
			self:setImg("a_ui_currency_btn_middle_4", "coach_ui", "level_up_btn")
		else
			self:setImg("a_ui_currency_btn_middle_2", "coach_ui", "level_up_btn")
		end
	end
	
end

return M