local M = class("MagicWeaponView",LikeOO.OOPopBase)

M.m_uiName = "MagicWeapon/MagicWeapon"
M.m_iphoneXAdapter = true

function M:onEnter()
	self.do_tween_tab = {}
	self.cache_attrs = {} --缓存属性信息
	self.effect_back =self:findGameObject("effect_back")
	self.effect_front =self:findGameObject("effect_front")
	self:setObjectVisible("cultivate_btn", false)
	self.m_gray_img = self:findImage("gray_img")
	self.right_parent = self:findGameObject("right_parent")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 16})
    self:refreshUI()
	self:setTextByLanKey("close_title_text", "weapon_str_0002")
	self:setTextByLanKey("wea_des_title_text", "weapon_str_0008")
	self:setTextByLanKey("level_up_text", "mystic_str_0042")
end

function M:refreshUI(play_anim)
	for i = 1,4 do
		local gua_weapon = self:findGameObject("gua_"..i)
		self:updateWeaponItem(gua_weapon, i)
	end
	self:updateRightSelectUI(play_anim)
	--快速导航
	self:setObjectVisible("guide_btn", true)
end

--右侧选中法宝属性信息
function M:updateRightSelectUI(play_anim)
	local cur_cfg = self.m_model:getTreasureConfig(self.m_model.m_select_id)
	local cur_data = self.m_model:getWeaponData(self.m_model.m_select_id)
	self:setObjectVisible("skill_max_btn", false)
	self:updateWeaEffect(cur_cfg)
	self:setObjectVisible("reset_btn_obj", false)
	if cur_cfg then
		local show_cfg = cur_cfg.detail[cur_data.lv] or cur_cfg.detail[1]
		local wear_id = self.m_model:getWeaponIdBySlot(cur_cfg.position) --当前槽位装备的技能
		local skill_cfg = self.m_model:getSkillDataById(show_cfg.skill_id)
		local lv = cur_data.lv or 1
		local lv_max = show_cfg.skill_limit
		if show_cfg then
			self:setTextByLanKey("wea_lv", "weapon_str_0009", cur_data.lv or 1)
			self:setTextByLanKey("buff_type_text", "weapon_str_0007", Language:getTextByKey(show_cfg.att_unit_tips) )
			self:setTextByLanKey("wea_des_text", show_cfg.des)
			self:setTextByLanKey("skill_lv", cur_data.lv or 1)
			if skill_cfg then
				self:setTextByLanKey("skill_des_text",  skill_cfg.des)
				self:setTextByLanKey("wea_skill_text", skill_cfg.name)
				self:setImg(skill_cfg.icon, "skill_icon","skill_icon")
			end
			if show_cfg.size and show_cfg.size > 0 then
				local wea_scale = self:findGameObject("wea_scale")
				UIUtil.setScale(wea_scale.transform,show_cfg.size, show_cfg.size)
			end
			local name_img = self:findImage("name_img") -- 
			GameUtil:updateResourcesImg(name_img, "Texture/zh_cn/"..show_cfg.name)
			if show_cfg.new_type == 0 then
				local wea_icon_img = self:findImage("big_wea_icon") -- 
				GameUtil:updateResourcesImg(wea_icon_img, "Texture/common/"..show_cfg.img)
				self:setObjectVisible("big_wea_icon", true)
			else
				self:setObjectVisible("big_wea_icon", false)	
			end
	
			self:setTextByLanKey("title_lv_text", "("..lv.."/"..lv_max..")")
			if play_anim == nil or play_anim == false then
				if show_cfg.att then
					self.cache_attrs = {}
					for i = 1,3 do
						if show_cfg.att[i] then
							local cur_atr_data = show_cfg.att[i]
							self:updateAttrItem(i, cur_atr_data)
						end
					end
				end
			else
				self.m_control:setOnceTimer(0.5, function ()
					if show_cfg.att then
						for i = 1,3 do
							if show_cfg.att[i] then
								local cur_atr_data = show_cfg.att[i]
								self:playAttrNums(i, cur_atr_data)
							end
						end
					end
				end)
			end
			--升级消耗
			local cost_data = RewardUtil:getProcessRewardData(show_cfg.cost[1])
			if cost_data then
				self:setImg(cost_data.icon_name, cost_data.atlas_name, "cost_img")
				local cost_text = self:setTextByLanKey("cost_num", cost_data.user_num.."/"..cost_data.data_num)
				if cost_data.user_num >= cost_data.data_num then
					cost_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
				else
					cost_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
				end
			end	
		end	
		self:setObjectVisible("skill_max_btn", lv < lv_max)
		if cur_cfg.unlock <= self.m_model.m_unlock_lv then
			self:setObjectVisible("btns", true)
			self:setObjectVisible("right_lock", false)
			local use_text =self:findGameObject("use_text")
			if wear_id == self.m_model.m_select_id then
				local btn = self:setImg("a_ui_currency_btn_middle_4", "coach_ui", "use_btn")
				self:setTextByLanKey("use_text", "weapon_str_0011")
				UIUtil.setOutlineExEffectColor(btn.transform,"use_text", Color.New(90/255,90/255,90/255,70/255),1)
			else
				local btn = self:setImg("a_ui_currency_btn_middle_2", "coach_ui", "use_btn")
				self:setTextByLanKey("use_text", "new_str_0048")
				UIUtil.setOutlineExEffectColor(btn.transform,"use_text", Color.New(155/255,80/255,7/255,70/255),1)
			end
		else
			self:setObjectVisible("btns", false)
			self:setObjectVisible("right_lock", true)	
			self:setTextByLanKey("lock_text", "weapon_str_0001", cur_cfg.unlock)
		end

		if cur_cfg.type == 1 then
			self:setObjectVisible("reset_btn_obj", lv > 1)
			self:setObjectVisible("level_up_btn_obj", lv < lv_max)
			self:setObjectVisible("bang_type_img", false)
			self:setObjectVisible("jump_obj", false)
		else --帮会法宝
			self:setObjectVisible("reset_btn_obj", false)
			self:setObjectVisible("bang_type_img", true)
			self:setObjectVisible("level_up_btn_obj", false)
			self:setObjectVisible("jump_obj", true)
			if next(cur_data) == nil then
				self:setObjectVisible("btns", false)
				self:setObjectVisible("right_lock", true)
				self:setTextByLanKey("lock_text", "weapon_str_0020")
			end
		end
	end
	local heros = self.m_model:getWeaHeros()
	if next(heros) ~= nil then
		self:setObjectVisible("hero_jc_btn", true)
	else
		self:setObjectVisible("hero_jc_btn", false)	
	end
end

--选中法宝特效
function M:updateWeaEffect(cur_cfg)
	UIUtil.destroyAllChild(self.effect_back.transform)
	UIUtil.destroyAllChild(self.effect_front.transform)
	if cur_cfg then
		local show_cfg = cur_cfg.detail[1]
		local effect_name = show_cfg.Special -- "UI_Magic_LianYH"
		local fx_ui_effect = ResourceUtil:GetUIEffectItem("MagicWeapon/"..effect_name.."_001")
		local bk_ui_effect = ResourceUtil:GetUIEffectItem("MagicWeapon/"..effect_name.."_002")
		if not IsNull(fx_ui_effect) then
			fx_ui_effect.transform:SetParent(self.effect_front.transform, false)
		end
		if not IsNull(bk_ui_effect) then
			bk_ui_effect.transform:SetParent(self.effect_back.transform, false)
		end
	end
end

--属性信息
function M:updateAttrItem(index, cell_data)
	local atr_key = GameUtil:getAttrsKey(cell_data[1])
	local atr_name = GameUtil:getAttrsName(atr_key)
	local cur_num = cell_data[2] or 0
	if GameUtil:canPerAttrTransition(atr_key) == true then
		cur_num = cur_num*100
	end
	self.cache_attrs[index] = cur_num
	if GameUtil:attrTransition(atr_key) == true then 
		self:setTextByLanKey("attr_num"..index, GameUtil:formatNum(cur_num).."%")
	else
		self:setTextByLanKey("attr_num"..index, GameUtil:formatNum(cur_num))
	end
	self:setTextByLanKey("attr_name"..index, atr_name)
end

--播放属性滚动
function M:playAttrNums(index, cell_data)
	local atr_key = GameUtil:getAttrsKey(cell_data[1])
	local atr_name = GameUtil:getAttrsName(atr_key)
	local cur_num = cell_data[2] or 0
	if GameUtil:canPerAttrTransition(atr_key) == true then
		cur_num = cur_num*100
	end
	self:setTextByLanKey("attr_num"..index, atr_name)
	local do_tween = self:AttrNumberChange("attr_num"..index, self.cache_attrs[index], cur_num, GameUtil:attrTransition(atr_key))
	table.insert(self.do_tween_tab, do_tween)
	if cur_num ~= self.cache_attrs[index] then
		self:setObjectVisible("attr_effect_"..index, true)
		self.m_control:setOnceTimer(0.3, function ()
			self:setObjectVisible("attr_effect_"..index, false)
		end)
	end
	self.cache_attrs[index] = cur_num
end

function M:AttrNumberChange(text_name, num1, num2, show_trans)
	if num2 > num1 then
		local sequence = Tweening.DOTween.Sequence()
		sequence:SetAutoKill(false)
		sequence:Append(Tweening.DOTween.To(function(index)
			if show_trans == true then
				local num_text = string.format("%.2f", index)
				self:setText(text_name,  num_text.."%")
			else
				self:setText(text_name,  num_text)		
			end
		end, num1, num2, 0.5))
		self.m_control:setOnceTimer(0.6, function ()
			if show_trans == true then
				self:setText(text_name,  GameUtil:formatNum(num2).."%")
			else
				self:setText(text_name,  GameUtil:formatNum(num2))		
			end
		end)
		return sequence
	else
		if show_trans == true then
			self:setText(text_name,  GameUtil:formatNum(num2).."%")
		else
			self:setText(text_name,  GameUtil:formatNum(num2))		
		end
	end
	return nil
end

--法宝槽位
function M:updateWeaponItem(obj, index)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local data = self.m_model:getWeaponData(index)
	local pos_cfg = self.m_model:getTreasurePosition(index)
	if luaBehaviour then
		local treasure = {}
		local seascon = UserDataManager:getCurSeason()
		if pos_cfg.treasure_s and pos_cfg.treasure_s[seascon] then
			treasure = pos_cfg.treasure_s[seascon]
		else
			treasure = pos_cfg.treasure
		end
		if self.m_model:checkSlotOpen(index) == true then
			local treasure_tab = self.m_model:getTreasureSort(index, treasure)
			local child_num = obj.transform.childCount
			for i,v in pairs(treasure) do
				local tre_cfg = self.m_model:getTreasureConfig(v)
				if tre_cfg then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_"..i.."_img", true)	
					self:updateWeaponObj(i,v,obj)
				else
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_"..i.."_img", false)	
				end
			end
		else
			for i,v in pairs(treasure) do
				local tre_cfg = self.m_model:getTreasureConfig(v)
				if tre_cfg then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_"..i.."_img", true)	
					self:updateLockWeaponObj(i,v,obj)
				else
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_"..i.."_img", false)	
				end
			end
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img_1", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img_2", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img_3", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img_4", true)
		end
	end
end

--开启的法宝
function M:updateWeaponObj(i, id, obj)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local tre_cfg = self.m_model:getTreasureConfig(id)
	local tre_data = self.m_model:getWeaponData(id)
	if tre_cfg == nil then
		return
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bang_img_"..i, tre_cfg.type == 2)
	local cur_data = tre_cfg.detail[tre_data.lv]
	local new_wea = self.m_model:checkNewWeapon(id)
	if tre_cfg and tre_cfg.type == 2 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_"..i.."_img", self.m_model:WeaponBangType(id) == true)
	end
	if cur_data then
		local wea_img = LuaBehaviourUtil.setImg(luaBehaviour, "wea_icon_"..i, cur_data.icon, "mystic_ui")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "new_img_"..i, new_wea == true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_lv_bg_"..i, true)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tre_lv_num_"..i, tre_data.lv)
	
		local cost_reward = RewardUtil:getProcessRewardData(cur_data.cost[1])
        if new_wea == false and cost_reward.user_num >= cost_reward.data_num and tre_data.lv < cur_data.skill_limit then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_"..i, true)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_"..i, false)	
        end
		if i == 1 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MagicWeapon_ShiYong_001", true)
		end
		if not IsNull(wea_img) then
			if tre_cfg.unlock > self.m_model.m_unlock_lv then
				wea_img.material = self.m_gray_img.material
			else
				wea_img.material = nil
			end
		end
	else
		local cur_data = tre_cfg.detail[1]
		local wea_img = LuaBehaviourUtil.setImg(luaBehaviour, "wea_icon_"..i, cur_data.icon, "mystic_ui")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "new_img_"..i, false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_lv_bg_"..i, false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_"..i, false)
		if i == 1 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MagicWeapon_ShiYong_001", false)
		end
		if not IsNull(wea_img) then
			wea_img.material = self.m_gray_img.material
		end
	end
	
	if tre_cfg.type == 1 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img_"..i, tre_cfg.unlock > self.m_model.m_unlock_lv )
	else
		if cur_data then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img_"..i, false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img_"..i, true)	
		end
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img_"..i, self.m_model.m_select_id == id)
 	UIUtil.setButtonClick(obj.transform, function(trans, data)
		if new_wea == true then
			self.m_model:clickNewWeapon(id)
		end
		self:updateMsg("select_id", id)
    end,nil, "tre_"..i.."_img")
end

--未开启的法宝
function M:updateLockWeaponObj(i, id, obj)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local tre_cfg = self.m_model:getTreasureConfig(id)
	if tre_cfg == nil then
		return
	end
	local tre_data = self.m_model:getWeaponData(id)
	local cur_data = tre_cfg.detail[1]
	if cur_data then
		local wea_img = LuaBehaviourUtil.setImg(luaBehaviour, "wea_icon_"..i, cur_data.icon, "mystic_ui")
		wea_img.material = self.m_gray_img.material
	end
	if tre_cfg and tre_cfg.type == 2 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_"..i.."_img", self.m_model:WeaponBangType(id) == true)
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tre_lv_bg_"..i, false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "new_img_"..i, false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_"..i, false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bang_img_"..i, tre_cfg.type == 2)
	if i == 1 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MagicWeapon_ShiYong_001", false)
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img_"..i, true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img_"..i, self.m_model.m_select_id == id)
 	UIUtil.setButtonClick(obj.transform, function(trans, data)
		self:updateMsg("select_id", id)
    end,nil, "tre_"..i.."_img")
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	for k,v in pairs(self.do_tween_tab) do
		if v then
			v:Kill()
		end
	end
	self.do_tween_tab = {}
    M.super.destroy(self)
end

return M