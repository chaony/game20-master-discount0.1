---@class HeroAttributeNode:OOUIbase
---@field m_model HeroBagModel
local M = class("HeroAttributeNode",LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroAttributeNode"

local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币
local tab_yueli = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} --粉尘

M.E_Color = Color( 255/255, 253/255, 247/255)
M.U_Color = Color( 241/255, 67/255, 31/255)

M.Sk_JieSuo = "UI_HeroInfo_JieSuo_001"
M.Sk_ShengJi = "UI_HeroInfo_Shengji_001"

M.SKILL_POS_3 = {
	{pos = Vector3(-70, 17, 0)},
	{pos = Vector3(0, -19, 0)},
	{pos = Vector3(70, 17, 0)},
}
M.SKILL_POS_4 = {
	{pos = Vector3(-103, 17, 0)},
	{pos = Vector3(-36, -19, 0)},
	{pos = Vector3(36, -19, 0)},
	{pos = Vector3(103, 17, 0)}
}

function M:onEnter()
	self:initCreatLvEffect()
	self:setTextByLanKey("apostle_rm_text", "guihuan_text")
	self:setTextByLanKey("in_crystal_text", "new_str_0207")
	self:setTextByLanKey("in_crystal_btn_text", "new_str_0488")
	self:setTextByLanKey("attack_text", "new_str_0392")
	self:setTextByLanKey("hp_text", "fb_str_0028")
	self:setTextByLanKey("def_text", "new_str_0505")
	self:setTextByLanKey("hero_lv_text", "new_str_0436")
	self:setTextByLanKey("reset_btn_text", "new_str_0432")
	self.atte_sq = {}
	local function m_levelupclick()
		self:updateMsg("pass_on")
	end
	local function m_levelupclickup()
		self:updateMsg("click_up")
	end
	self:addActionChangAn("levet_up_btn", m_levelupclickup, m_levelupclick)
	self:refreshUI()
	self:setTextByLanKey("level_up_text", "new_str_0488")
	self:enterSetSkillRedPoint()
end

function M:updateEquipState(bl)
	self.equip_state_bl = bl
	if bl == false then
		self:clearAnim()
	end
end

function M:refreshUI()
	self:updateProType()
	self:updateViewInfo()
	self:setLevelUp()
	self:updateSkill()
	self:setObjectVisible("cell_grade_obj", self.m_model.m_hero_list_type ~= 2)
	self:setObjectVisible("cell_tj_text", self.m_model.m_hero_list_type == 2)
	local temp_cfg = self.m_model:getCurHeroCfg()
	self:setTextByLanKey("cell_tj_text", temp_cfg.des)
	self:setObjectVisible("reset_btn", false)
	if self.m_model.m_mode == 3 then
		self:setObjectVisible("cell_grade_obj", false)
	else
		if self.m_model.m_hero_list_type ~= 2 then -- 不是图鉴
			local h_data, h_cfg = self.m_model:getSelectHeroData()
			local cur_lv = self.m_model.m_cur_Lv
			local lv_flag = false
			if h_data.lv > 1 then
				lv_flag = true
			elseif cur_lv > 1 and h_data.clv == 0 then
				lv_flag = true
			end
			local evo = self.m_model:getEvo()
			if lv_flag or evo > 6 then
				self:setObjectVisible("reset_btn", true)
			end
		end
	end
	self:updateBtnState()
	self:setFatesState()
	self:setCombatRepressText()
end

function M:refreshLevelUpUI()
	self:refreshUI()
end

--设置战力压制的值
function M:setCombatRepressText()
	if BtnOpenUtil:isBtnOpen(402) and self.m_model.m_mode == 1 then
		local _,nums = GameUtil:countCombatRepressGrade(self.m_model.m_selected_id)
		local _,nums2 = GameUtil:countGlobalCombatRepressGrade()
		self:setTextByLanKey("main_bd_btn_text", "combat_suppress_system_text_003",nums+nums2)
		self:setObjectVisible("combat_suppress_btn",true)
	else
		self:setObjectVisible("combat_suppress_btn",false)
	end
end

--设置天命化星状态
function M:setFatesState()
	self:setObjectVisible("star_img",false)
	self:setObjectVisible("combat_img",true)
	local hero_Data = self.m_model:getSelectHeroData()
	local star_id,is_fate = self.m_model:getFatesInfo(hero_Data.oid)
	if is_fate then
		local star_info = self.m_model:getFateByStarId(star_id)
		local Img_bg = self:findGameObject("star_img")
		GameUtil:updateResourcesImg(Img_bg,"Texture/tmhx_start/"..star_info.star_icon)
		self:setTextByLanKey("no_lv_tips", "")
		--self:setTextByLanKey("skip_btn_text", "destinyStar_text_0009")
	end
end

function M:updateBtnState()
	local level_btn = self:setObjectVisible("levet_up_btn", false) --升级
	local skip_btn = self:setObjectVisible("skip_btn", false) --跳转
	local no_lv_tips = self:setObjectVisible("no_lv_tips", false) --进阶提示
	local in_crystal_btn = self:setObjectVisible("in_crystal_img", false) --共鸣水晶中
	local apostle_rm_btn = self:setObjectVisible("apostle_rm_btn", false) --归还佣兵
	local player_info_node = self:setObjectVisible("player_info_node", false) --其他玩家信息
	-- local link_btn = self:setObjectVisible("linkage_btn", false) --联动英雄信息
	local resour_bg = self:setObjectVisible("resour_bg", false) --资源底
	local resour_obj = self:setObjectVisible("resour_obj", false) --资源条
	if self.m_model.m_mode == 3 then
		--其他玩家信息
		player_info_node:SetActive(true)
		if self.m_model.m_apostle then
			apostle_rm_btn:SetActive(true)
		end
		-- elseif self.m_model:IsLink() == true then	--103
		-- 	link_btn:SetActive(true)
		return
	end
	local isMaxLv = self.m_model:checkMaxLv()
	local isEvoMax = self.m_model:checkEvoMax()
	local isMaxEvo = self.m_model:checkMaxEvo()
	if isMaxLv == true and isEvoMax == true then
		--到达游戏内英雄等级上限---300
		--跳转练武场
		self:setTextByLanKey("no_lv_tips", "new_str_0708")
		self:setTextByLanKey("skip_btn_text", "new_str_0620")
		no_lv_tips:SetActive(true)
		skip_btn:SetActive(true)
		self:stopLevelup()
	elseif isMaxLv == true and isMaxEvo == false then
		--到达游戏内英雄当前品质上限 根据evo
		--跳转传功殿
		self:setTextByLanKey("no_lv_tips", "new_str_0619")
		self:setTextByLanKey("skip_btn_text", "new_str_0707")
		self:stopLevelup()
		no_lv_tips:SetActive(true)
		skip_btn:SetActive(true)
	elseif isMaxLv == true and isMaxEvo == true then
		self:setTextByLanKey("no_lv_tips", "new_str_0709")
		no_lv_tips:SetActive(true)
		--elseif false then
		--归还佣兵
		--apostle_rm_btn:SetActive(true)
	elseif self.m_model:inCrystal() == true then
		--共鸣水晶中不可升级
		in_crystal_btn:SetActive(true)
		self:stopLevelup()
	else
		--升级
		level_btn:SetActive(true)
		resour_bg:SetActive(true)
		resour_obj:SetActive(true)
	end
end

--英雄类型
function M:updateProType()
	local temp_cfg = self.m_model:getCurHeroCfg()
	if temp_cfg then
		local type_data = GlobalConfig.TYPE_HERO_PROPERTY[temp_cfg.type]
		local locate1_data = GlobalConfig.TYPE_HERO_LOCATION_1[temp_cfg.locate[1] or 1]
		local locate2_data = GlobalConfig.TYPE_HERO_LOCATION_2[temp_cfg.locate[2] or 1]
		self:setImg(type_data.pro_icon, "hero_ui", "pro_img_1")
		self:setImg(locate1_data.loc_icon, "hero_ui", "pro_img_2")
		self:setImg(locate2_data.loc_icon, "hero_ui", "pro_img_3")
		self:setTextByLanKey("pro_text_1", type_data.name)
		self:setTextByLanKey("pro_text_2", locate1_data.name)
		self:setTextByLanKey("pro_text_3", locate2_data.name)
	end
end

--英雄属性
function M:updateViewInfo()
	local cur_attrs = table.copy(self.m_model:getHeroAttrs())
	local cur_comb = self.m_model:getHero_Combat()
	local last_attrs = self.m_model.last_attrs
	local last_lv = self.m_model.last_lv
	local last_comb = self.m_model.last_combat or cur_comb
	if self.m_model.m_hero_list_type ~= 2 then --不是图鉴信息
		if cur_comb > last_comb then
			self:AddCombatNumber(last_comb, cur_comb)
		else
			if self.m_sequence then
				self.m_sequence:Kill()
				self.m_sequence = nil
			end
			self:setText("combat_text", GameUtil:formatValueToString(cur_comb))
		end
	else
		self:setText("combat_text", GameUtil:formatValueToString(cur_comb))
	end
	local cur_lv = self.m_model:getHero_lv()
	if self.m_model.m_hero_list_type ~= 2 and self.m_model.m_mode ~= 3 then
		self:lvZoom(last_lv, cur_lv)
	end
	self:setTextByLanKey("lv_main_text", cur_lv)
	self:updateAttrs(cur_attrs)
end

--更新技能信息
function M:updateSkill()
	local skills = self.m_model:getHeroSkill()
	for i = 1,4 do
		self:setObjectVisible("skill"..i.."_img",false)
		self:setObjectVisible("di_"..i, false)
	end
	for k,v in pairs(skills) do
		if k <= 4 then
			local str_name = "skill"..k.."_img"
			local show_text = "skill_"..k.."_text"
			local locklv = v[1][2] --解锁等级
			local cur_skill = GameUtil:getSkill(v[1][1])
			local sk_img_name = "skill"..k.."_img"
			local sk_gary_img_name ="skill"..k.."_img_gray"
			local sk_t ="sk_"..k
			if cur_skill ~= nil then
				self:setTextByLanKey(show_text, self.m_model:chrckSkillLvByIndex(k))
				self:setTextByLanKey(sk_t, cur_skill.show_type)
				self:setImg(cur_skill.icon, "skill_icon", str_name)
				self:setImg(cur_skill.icon, "skill_icon", sk_gary_img_name)
				self:setObjectVisible(sk_img_name,true)
				self:setObjectVisible("di_"..k, true)
				local lv = self.m_model:getHero_lv()
				local bl = lv < locklv
				self:setObjectVisible(sk_gary_img_name,bl)
			end
		end
	end
	if skills[4] then
		self:setObjectVisible("skill_effect_4", true)
		for k,v in pairs(self.SKILL_POS_4) do
			local skill_bg = self:findGameObject("di_"..k)
			local skill_ef = self:findGameObject("skill_effect_"..k)
			if not IsNull(skill_bg) then
				skill_bg.transform.localPosition = v.pos
			end
			if not IsNull(skill_ef) then
				skill_ef.transform.localPosition = v.pos
			end
		end
	else
		self:setObjectVisible("skill_effect_4", false)
		for k,v in pairs(self.SKILL_POS_3) do
			local skill_bg = self:findGameObject("di_"..k)
			local skill_ef = self:findGameObject("skill_effect_"..k)
			if not IsNull(skill_bg) then
				skill_bg.transform.localPosition = v.pos
			end
			if not IsNull(skill_ef) then
				skill_ef.transform.localPosition = v.pos
			end
		end
	end
end

-- 英雄升级需要消耗
function M:setLevelUp()
	local up_expend = GameUtil:getHeroUpGrade(self.m_model.m_cur_Lv)
	local need_exp = up_expend.exp
	local need_coin = up_expend.coin
	local need_special = up_expend.special_num
	local cur_exp = self.m_model.data_exp.user_num
	local cur_coin = self.m_model.data_coin.user_num
	local cur_special = self.m_model.data_special.user_num
	local my_text = self:setText("money_text", GameUtil:formatValueToString(need_coin))
	local jy_text = self:setText("jingyan_text", GameUtil:formatValueToString(need_exp))
	local yl_text = self:setText("yueli_text", GameUtil:formatValueToString(need_special))
	if need_coin > cur_coin then
		my_text.color = self.U_Color
	else
		my_text.color = self.E_Color
	end
	if need_exp > cur_exp then
		jy_text.color = self.U_Color
	else
		jy_text.color = self.E_Color
	end
	if need_special > cur_special then
		yl_text.color = self.U_Color
	else
		yl_text.color = self.E_Color
	end
	self:setImg(self.m_model.data_coin.icon_name, self.m_model.data_coin.atlas_name, "money_img")	--金币
	self:setImg(self.m_model.data_exp.icon_name, self.m_model.data_exp.atlas_name, "jingyan_img")	--英雄经验
	self:setImg(self.m_model.data_special.icon_name, self.m_model.data_special.atlas_name, "yueli_img")	--特殊
	if need_special > 0 then -- 是否消耗特殊材料
		self:setObjectVisible("res_yueli_obj",true)
	else
		self:setObjectVisible("res_yueli_obj",false)
	end
end

function M:updateAttrs(attrs)
	if self.m_model.last_attrs ~= nil and next(self.m_model.last_attrs) ~= nil then
		for k,v in pairs(self.atte_sq) do
			if v then
				v:Kill()
				v = nil
			end
		end
		for k,v in pairs(self.m_model.last_attrs) do
			local last_h, cur_h = v, attrs[k]
			if cur_h > last_h then
				if k == "hp" then
					self:setTextByLanKey("hp_num",  GameUtil:formatValueToString(last_h))
					self:AddAtteNumber("hp_num", last_h, cur_h)
				elseif k == "atk" then
					self:setTextByLanKey("attack_num",  GameUtil:formatValueToString(last_h))
					self:AddAtteNumber("attack_num", last_h, cur_h)
				elseif k == "def" then
					self:setTextByLanKey("def_num",  GameUtil:formatValueToString(last_h))
					self:AddAtteNumber("def_num", last_h, cur_h)
				end
			else
				if k == "hp" then
					self:setTextByLanKey("hp_num",  GameUtil:formatValueToString(cur_h))
				elseif k == "atk" then
					self:setTextByLanKey("attack_num",  GameUtil:formatValueToString(cur_h))
				elseif k == "def" then
					self:setTextByLanKey("def_num",  GameUtil:formatValueToString(cur_h))
				end
			end
		end
	else
		self:setTextByLanKey("hp_num",  GameUtil:formatValueToString(attrs["hp"]))
		self:setTextByLanKey("attack_num", GameUtil:formatValueToString(attrs["atk"]))
		self:setTextByLanKey("def_num", GameUtil:formatValueToString(attrs["def"]))
	end
end

function M:AddCombatNumber(num1, num2)
	if IsNull(self.add_combat) then
		return
	end
	if self.add_combat_sequence then
		self.add_combat_sequence:Kill()
		self.add_combat_sequence = nil
	end
	if self.combat_time then
		self.m_control:removeTimer(self.combat_time)
		self.combat_time = nil
	end
	local show_text = self:setText("combat_text", GameUtil:formatValueToString(num1))
	local text_rt = show_text.gameObject:GetComponent("RectTransform")
	local rect = text_rt.rect
	local num = rect.height
	local combat_text = UIUtil.findText(self.add_combat.transform)
	combat_text.text = "+"..(num2 - num1)
	self.add_combat.transform.localPosition = Vector3.New(-125, (num - 92),  0)
	UIUtil.setTextColor(self.add_combat.transform, Color(74/255,237/255,109/255,1))
	self.add_combat:SetActive(true)
	local function awaitPlay()
		if not IsNull(self.add_combat) then
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(self.add_combat.transform:DOLocalMoveY(0, 0.5))
			sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0, 0.5))
			sequence:OnComplete(function ()
				if self.equip_state_bl == false then
					return nil
				end
				if not IsNull(self.add_combat) then
					self.m_sequence = self:NumberChange(num1, num2)
					--self:setText("combat_text", GameUtil:formatValueToString(num2))
					self.add_combat:SetActive(false)
				end
				audio:SendEvtUI("Play_UI_Power_Increase")
			end
			)
			sequence:SetAutoKill(false)
			self.add_combat_sequence = sequence
		end
		if self.combat_time then
			self.m_control:removeTimer(self.combat_time)
			self.combat_time = nil
		end
	end
	self:combatZoom()
	self.combat_time = self.m_control:setTimer(0.5, awaitPlay)
end

function M:lvZoom(last_lv, cur_lv)
	if last_lv and cur_lv and cur_lv > last_lv then
		local lv_text = self:findGameObject("lv_main_text")
		GameUtil:ZoomObj(lv_text)
	end
end

function M:AddAtteNumber(text_name, num1, num2)
	if self.m_sequence2 and self.m_sequence2[text_name] then
		self.m_sequence2[text_name]:Kill()
		self.m_sequence2[text_name] = nil
	end
	if self.m_attr_time[text_name] then
		self.m_control:removeTimer(self.m_attr_time[text_name])
		self.m_attr_time[text_name] = nil
	end
	local show_text = self:findText(text_name)
	local text_rt = show_text.gameObject:GetComponent("RectTransform")
	local rect = text_rt.rect
	local num = rect.width
	local add_comb = self.add_attr[text_name]
	local combat_text = UIUtil.findText(add_comb.transform)
	combat_text.text = "+"..(num2 - num1)
	local pos_x = (num + 10)
	add_comb.transform.localPosition = Vector3.New(pos_x, 0, 0)
	UIUtil.setTextColor(add_comb.transform, Color(74/255,237/255,109/255,1))
	add_comb:SetActive(true)
	if self.m_control then
		local function awaitPlay()
			if not IsNull(add_comb) then
				local sequence = Tweening.DOTween.Sequence()
				sequence:Append(add_comb.transform:DOLocalMoveX(-20, 0.5))
				sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0, 0.5))
				sequence:OnComplete(function ()
					if self.equip_state_bl == false then
						return nil
					end
					add_comb:SetActive(false)
					if not IsNull(add_comb) then
						self.atte_sq[text_name] = self:AttrNumberChange(text_name, num1, num2)
					end
					audio:SendEvtUI("Play_UI_Power_Increase")
				end
				)
				sequence:SetAutoKill(false)
				self.m_sequence2[text_name] = sequence
			end
			if self.m_attr_time[text_name] then
				self.m_control:removeTimer(self.m_attr_time[text_name])
				self.m_attr_time[text_name] = nil
			end
		end
		self.m_attr_time[text_name] = self.m_control:setTimer(0.5, awaitPlay)
	end
end

function M:onButtonClick(obj, name)
	if name == "pro_1" then
		self:clickProTips1(name)
	elseif name == "pro_2" then
		self:clickProTips2(name)
	elseif name == "pro_3" then
		self:clickProTips3(name)
	elseif name == "money_img" or name == "jingyan_img" or name == "yueli_img" then
		self:clickTips(name)
	else
		M.super.onButtonClick(self, obj, name)
	end
end

function M:clickTips(str)
	local m_data = {top = true}
	if str == "money_img" then
		local cur_obj = self:findGameObject("money_img")
		m_data.click_transform = cur_obj.transform
		m_data.data = tab_money
	elseif 	str == "jingyan_img" then
		local cur_obj = self:findGameObject("jingyan_img")
		m_data.click_transform = cur_obj.transform
		m_data.data = tab_exp
	elseif str == "yueli_img" then
		local cur_obj = self:findGameObject("yueli_img")
		m_data.click_transform = cur_obj.transform
		m_data.data = tab_yueli
	end
	GameUtil:lookInfoTips(self.m_control, m_data)
end

function M:clickProTips1(str)
	local temp_cfg = self.m_model:getCurHeroCfg()
	local type_data = GlobalConfig.TYPE_HERO_PROPERTY[temp_cfg.type]
	local cur_cfg = self.m_model:getCurHeroCfg()
	local data_desc = type_data.des
	local btns = self:findGameObject(str)
	if btns then
		GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc) } )
	end
end

function M:clickProTips2(str)
	local temp_cfg = self.m_model:getCurHeroCfg()
	local locate1_data = GlobalConfig.TYPE_HERO_LOCATION_1[temp_cfg.locate[1] or 1]
	local cur_cfg = self.m_model:getCurHeroCfg()
	local data_desc = locate1_data.des
	local btns = self:findGameObject(str)
	if btns then
		GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc) } )
	end
end

function M:clickProTips3(str)
	local temp_cfg = self.m_model:getCurHeroCfg()
	local locate2_data = GlobalConfig.TYPE_HERO_LOCATION_2[temp_cfg.locate[2] or 1]
	local cur_cfg = self.m_model:getCurHeroCfg()
	local data_desc = locate2_data.des
	local btns = self:findGameObject(str)
	if btns then
		GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc) } )
	end
end

function M:enterSetSkillRedPoint()
	for i = 1,4 do
		self:setObjectVisible("skill_point_"..i, false)
	end
end

function M:updateSkillRedPoint(index, bl)
	self:setObjectVisible("skill_point_"..index, bl)
end

function M:creatEffect(tx_name, prent)
	local item = ResourceUtil:GetUIEffectItem("HeroInfo/"..tx_name, prent)
	return item
end

function M:creatCurEffect(index, new_bl)
	local prent = self:findGameObject("skill_effect_"..index)
	self.c_tx_obj = nil
	if new_bl == true then
		self.m_control:setOnceTimer(2, function()
			if self.c_tx_obj and not IsNull(self.c_tx_obj) then
				U3DUtil:Destroy(self.c_tx_obj)
			end
		end)
		self.c_tx_obj = self:creatEffect(self.Sk_JieSuo, prent)
	else
		self.m_control:setOnceTimer(1, function()
			if self.c_tx_obj and not IsNull(self.c_tx_obj)  then
				U3DUtil:Destroy(self.c_tx_obj)
			end
		end)
		self.c_tx_obj = self:creatEffect(self.Sk_ShengJi, prent)
		self:setParticleRenderOrder(self.c_tx_obj)
	end
end

function M:NumberChange(num1, num2)
	local sequence = Tweening.DOTween.Sequence()
	sequence:SetAutoKill(false)
	sequence:Append(Tweening.DOTween.To(function(index)
		local temp = math.floor(index)
		self:setText("combat_text", GameUtil:formatValueToString(temp))
	end, num1, num2, 0.5))
	return sequence
end

function M:initCreatLvEffect()
	self.m_sequence2 = {}
	self.m_attr_time = {}
	self.lv_effect = {} --升级特效预制
	self.add_combat = nil --战力改变飞入预制
	self.add_attr = {} --属性改变飞入预制
	local combat_text = self:findGameObject("combat_text")
	local hp_num = self:findGameObject("hp_num")
	local attack_num = self:findGameObject("attack_num")
	local def_num = self:findGameObject("def_num")
	local add_hp = self:creatEffect("add_combat", hp_num)
	local add_attack = self:creatEffect("add_combat", attack_num)
	local add_def = self:creatEffect("add_combat", def_num)
	self.add_attr["hp_num"] = add_hp
	self.add_attr["attack_num"] = add_attack
	self.add_attr["def_num"] = add_def
	self.add_combat = self:creatEffect("add_combat2", combat_text)
	local com_parent = self:findGameObject("com_eff")
	local property = self:findGameObject("property")
	local levet_up_btn = self:findGameObject("levet_up_btn")
	local effect = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_001", com_parent)
	local effect2 = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_002", property)
	local effect3 = ResourceUtil:GetUIEffectItem("Common/UI_Common_AnNiu_YellowBig_02", levet_up_btn)
	effect3.transform.localScale = Vector3.New(0.8, 1, 1)
	self:setParticleRenderOrder(effect)
	self:setParticleRenderOrder(effect2)
	self:setParticleRenderOrder(effect3)
	table.insert(self.lv_effect, effect)
	table.insert(self.lv_effect, effect2)
	table.insert(self.lv_effect, effect3)
	self.add_combat:SetActive(false)
	for k,v in pairs(self.lv_effect) do
		if not IsNull(v) then
			v:SetActive(false)
		end
	end
	for k,v in pairs(self.add_attr) do
		if not IsNull(v) then
			v:SetActive(false)
		end
	end
end

function M:combatZoom()
	if self.lv_lizi_time then
		self.m_control:removeTimer(self.lv_lizi_time)
		for k,v in pairs(self.lv_effect) do
			if not IsNull(v) then
				v:SetActive(false)
			end
		end
		self.lv_lizi_time = nil
	end
	for k,v in pairs(self.lv_effect) do
		if not IsNull(v) then
			v:SetActive(true)
		end
	end
	if self.m_control then
		self.lv_lizi_time = self.m_control:setTimer(
				1,
				function()
					if self.lv_lizi_time then
						self.m_control:removeTimer(self.lv_lizi_time)
						for k,v in pairs(self.lv_effect) do
							if not IsNull(v) then
								v:SetActive(false)
							end
						end
						self.lv_lizi_time = nil
					end
				end
		)
	end
end

function M:AttrNumberChange(text_name, num1, num2)
	if self.equip_state_bl == false then
		return nil
	end
	local sequence = Tweening.DOTween.Sequence()
	sequence:SetAutoKill(false)
	sequence:Append(Tweening.DOTween.To(function(index)
		local temp = math.floor(index)
		self:setText(text_name,  GameUtil:formatValueToString(temp))
	end, num1, num2, 0.5))
	return sequence
end

function M:setShowQuickLevelUp(lv)
	self:setObjectVisible("quick_levet_up_btn", lv > 0)
	self:setTextByLanKey("quick_levet_up_text", "hero_ui_str_0020", lv)
end

function M:stopLevelup()
	if self.m_luaBehaviour then
		local changAn_obj = self:findGameObject("levet_up_btn")
		local changAn_btn = changAn_obj:GetComponent("ChangAn")
		if changAn_btn then
			changAn_btn:StopClick(false)
		end
	end
end

function M:destroy()
	self:clearAnim()
	M.super.destroy(self)
end

function M:clearAnim()
	if self.lv_lizi_time then
		self.m_control:removeTimer(self.lv_lizi_time)
		self.lv_lizi_time = nil
	end
	if self.combat_time then
		self.m_control:removeTimer(self.combat_time)
		self.combat_time = nil
	end
	if self.add_combat_sequence then
		self.add_combat_sequence:Kill()
		self.add_combat_sequence = nil
	end
	if self.m_sequence2 then
		for i,v in pairs(self.m_sequence2) do
			v:Kill()
		end
	end
	self.m_sequence2 = {}
	if self.m_sequence then
		self.m_sequence:Kill()
		self.m_sequence = nil
	end
	for k,v in pairs(self.atte_sq) do
		if v then
			v:Kill()
		end
	end
	self.atte_sq = {}
	for i,v in pairs(self.m_attr_time) do
		self.m_control:removeTimer(v)
	end
	self.m_attr_time = {}
end

function M:getSkillIcon(index)
	return self:findGameObject(index)
end

return M