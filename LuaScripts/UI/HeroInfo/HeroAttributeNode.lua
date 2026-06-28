---@class HeroAttributeNode:OOUIbase
---@field m_model  HeroBagModel
--- 属性
local M = class("HeroAttributeNode", LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/HeroAttributeNode"
--M.m_iphoneXAdapter = true
local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币
local tab_yueli = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} --粉尘
                                                                                                                          
local DIA_TAB = {key = "m_diamond", data = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0}, icon_img = "money_img_3", icon_text = "count_num_3"}
M.E_Color = Color( 255/255, 253/255, 247/255)
M.U_Color = Color( 241/255, 67/255, 31/255)

M.Sk_JieSuo = "UI_HeroInfo_JieSuo_001"
M.Sk_ShengJi = "UI_HeroInfo_Shengji_001"

function M:onEnter()
	self.atte_sq = {}
	if self.m_model.m_show_new then
		self:setObjectVisible("new_text", true)
	else
		self:setObjectVisible("new_text", false)
	end
	self:setTextByLanKey("desc_text","new_str_0437")
	self:setTextByLanKey("close_text","new_str_0370")
    self:setTextByLanKey("skill_toggle_text","new_str_0025")
    self:setTextByLanKey("hero_toggle_text","new_str_0018")
	self:setTextByLanKey("new_text","new_str_0217")
	self:setTextByLanKey("camp_text", "hero_ui_str_0001")
	self:setTextByLanKey("pro_text", "hero_ui_str_0002")
	self:setTextByLanKey("skill_title_text", "new_str_0025")
	self:setTextByLanKey("pro_title_text", "hero_ui_str_0003")
	self:setTextByLanKey("put_on_text", "hero_ui_str_0004")
	self:setTextByLanKey("get_out_text", "hero_ui_str_0005")
	self:setTextByLanKey("hero_lv_text", "new_str_0436")
	self:setTextByLanKey("def_text", "new_str_0394")
	local function m_levelupclick()
		self:updateMsg("pass_on")
	end
	local function m_levelupclickup()
		self:updateMsg("click_up")
	end
	self:addActionChangAn("levet_up_btn", m_levelupclickup, m_levelupclick)
	self:setObjectVisible("player_info_node", false)
	self:setObjectVisible("apostle_rm_btn", false)
	if self.m_model.m_look_model == 1 then
		self:setObjectVisible("levet_up_btn_text", false)
		self:setObjectVisible("lock_btn", false)
		self:setObjectVisible("get_out_btn", false)
		self:setObjectVisible("put_on_btn", false)
		self:setObjectVisible("levet_up_btn", false)
		self:setObjectVisible("skip_btn", false)
		self:setObjectVisible("resources", false)
		self:setObjectVisible("desc_btn", false)
		self:setObjectVisible("category7_cont", false)
		self:setObjectVisible("in_crystal_img", false)
		local head_node = self:findGameObject("head_node")
		if self.m_model.m_player_data.user then
			self:setObjectVisible("player_info_node", true)
			GameUtil:setUserAvatar(head_node, self.m_model.m_player_data.user,nil,nil,{show_flag = true, scale = 1})
			self:setText("player_name_text", self.m_model.m_player_data.user.name)
		end
		if self.m_model.m_model_type == 1 then
			self:setObjectVisible("apostle_rm_btn", true)
			local pos = head_node.transform.localPosition
			UIUtil.setLocalPosition(head_node.transform,pos.x - 100, pos.y, 0)
			self:setTextByLanKey("apostle_rm_text", "new_str_0264")
			self:setObjectVisible("check_btn",false)
			self:setObjectVisible("player_name_text", false)
		end
		local cur_list_count = self.m_model:getHeroCurListCount()
		self:setObjectVisible("last_btn",cur_list_count > 1)
		self:setObjectVisible("next_btn",cur_list_count > 1)
	elseif self.m_model.m_look_model == 2 then
		self:setObjectVisible("lock_btn", false)
		self:setObjectVisible("get_out_btn", false)
		self:setObjectVisible("put_on_btn", false)
		self:setObjectVisible("levet_up_btn", false)
		self:setObjectVisible("skip_btn", false)
		self:setObjectVisible("resources", false)
		self:setObjectVisible("eqp_list",false)	
		self:setObjectVisible("last_btn",false)
		self:setObjectVisible("next_btn",false)
		self:setObjectVisible("check_btn",false)
		self:setObjectVisible("category7_cont", false)
		self:setObjectVisible("levet_up_btn_text", false)
		self:setObjectVisible("in_crystal_img", false)
	end
	self:creatNilEqp()
	self.cacheSpineName = ""
	self.is_run = false
	self:refreshUI(true)
	self:enterSetSkillRedPoint()
end

function M:refreshUI(bl)
	self:setViewInfo(bl)
	self:updateEquipInfo()
	self:updateSkill()
	self:setSpine()
	self:setTextByLanKey("in_crystal_btn_text", "shareLv_str_0013")
	self:setTextByLanKey("level_up_text","new_str_0488")
	if self.m_model.m_look_model == 0 then
		self:setLock()
	end
	self:setObjectVisible("resour_bg",true)
	self:setObjectVisible("resour_obj",true)
	--更新界面升级按钮相关状态信息
	if self.m_model.m_look_model == 0 or self.m_model.m_look_model == 3  then
		self:setObjectVisible("in_crystal_img", false)
		self:setObjectVisible("levet_up_btn", true)
		self:setObjectVisible("skip_btn", false)
		if self.m_model:inCrystal(self.m_model.m_heroid) == true then --神木中的英雄
			self:setObjectVisible("in_crystal_img", true)
			self:setTextByLanKey("in_crystal_text","new_str_0207")
			self:setObjectVisible("resour_bg",false)
			self:setObjectVisible("resour_obj",false)
			self:setObjectVisible("levet_up_btn", false)
			self:stopLevelup()
		elseif self.m_model:checkMaxLv() == true and self.m_model:checkEvoMax() then --到达游戏内英雄等级上限
			self:setObjectVisible("skip_btn", true) --跳转神木
			self:setTextByLanKey("skip_desc_text","new_str_0343")
			self:setTextByLanKey("skip_btn_text","前往练武场")
			self:setObjectVisible("levet_up_btn", false)
			self:stopLevelup()
			self:setObjectVisible("resour_bg",false)
			self:setObjectVisible("resour_obj",false)
		elseif self.m_model:checkMaxLv() == true and self.m_model:checkMaxEvo() == true then --到达等级上限
			self:setObjectVisible("in_crystal_img", true)
			self:setTextByLanKey("in_crystal_text","new_str_0341")
			self:setObjectVisible("resour_bg",false)
			self:setObjectVisible("resour_obj",false)
			self:setObjectVisible("levet_up_btn", false)
			self:stopLevelup()
		elseif 	self.m_model:checkMaxLv() == true then --到达当前进化等级上限 
			self:setTextByLanKey("skip_desc_text","new_str_0342") --跳转升阶
			self:setTextByLanKey("skip_btn_text","new_str_0344") 
			self:setObjectVisible("skip_btn", true)
			self:setObjectVisible("levet_up_btn", false)
			self:stopLevelup()
			self:setObjectVisible("resour_bg",false)
			self:setObjectVisible("resour_obj",false)
		end
	else
		self:setObjectVisible("resour_bg",false)
		self:setObjectVisible("resour_obj",false)
	end
	if self.m_model.m_look_model == 0 or self.m_model.m_look_model == 3 then
		if self.m_model:isCategory7() == true then --虚空英雄
			self:setObjectVisible("category7_cont", true)
			self:setObjectVisible("in_crystal_img", false)
			self:setObjectVisible("levet_up_btn", false)
			self:setObjectVisible("skip_btn", false)
		else
			self:setObjectVisible("category7_cont", false)
		end
	end
	if self.m_model.herocfg then
		if self.m_model.herocfg.id == 34 or self.m_model.herocfg.id == 37 then 
			self:setObjectVisible("ComUnfinishedTips", true)
		else
			self:setObjectVisible("ComUnfinishedTips", false)	
		end
	elseif self.m_model.tj_id then
		if self.m_model.tj_id == 34 or self.m_model.tj_id == 37 then 
			self:setObjectVisible("ComUnfinishedTips", true)
		else
			self:setObjectVisible("ComUnfinishedTips", false)	
		end
	else
		self:setObjectVisible("ComUnfinishedTips",false)
	end
	self:setObjectVisible("desc_btn_point", self.m_model:checkRedPoint())
end

--更新界面等级属性数据信息
function M:setViewInfo(bl)
	local cur_attrs = table.copy(self.m_model:getHeroAttrs())
	local cur_comb = self.m_model:getHero_Combat()
	local last_attrs = self.m_model.last_attrs
	local last_lv = self.m_model.last_lv
	local last_comb = self.m_model.last_combat
	if self.m_model.m_look_model ~= 2 and bl and bl == true then
		if self.rollText2 then
			self.m_control:removeTimer(self.rollText2)
			self.is_run = false	
		end
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
	if self.m_model.m_look_model ~= 2 and bl then
		self:lvZoom(last_lv, cur_lv)
	end
	self:setTextByLanKey("lv_main_text", "new_str_0075", cur_lv)
	self:updateAttrs(cur_attrs)
	self.m_model:detectionAttrs()
	self:setTextByLanKey("main_title_text", self.m_model:getHero_Name())
	for i = 1 ,3 do
		self:setObjectVisible("light_img_"..i, false)
	end
	self:setObjectVisible("light_img_"..self.m_model:getPro(), true)
	local race = GlobalConfig.TYPE_HERO_RACE[self.m_model:getRace()].big_race_icon --英雄种族icon
	self:setImg(race, ResourceUtil:getLanAtlas(), "hero_camp_img")
	local type = GlobalConfig.TYPE_HERO_PROPERTY[self.m_model:getPro()].pro_icon --英雄属性icon
	local common = GlobalConfig.QUALITY_FRAME[self.m_model:getEvo()].line_frame_name --英雄品质icon
	--self:setImg(common, "hero_ui", "base_img")
	local _,cfg=self.m_model:getSelectHeroData()
	self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,self.m_model:getEvo()), "hero_ui", "base_img")
	self:setObjectVisible("base_img", false)
	self:setObjectVisible("main_stars", false)
	if self.m_model:getEvo() > 11 then
		local lv = self.m_model:getEvo() - 11 or 0
		if lv > 0 then
			self:setObjectVisible("main_stars", true)
            for i = 1, 5 do
                local star = self:findGameObject("main_star_" .. i)
                if star then
                    star:SetActive(i <= lv)
                end
            end
		end 
	end
	self:setLevelUp()
end

function M:getSpineByEvo(lv)
	--self:setObjectVisible("zise_spine", false)
	--self:setObjectVisible("jinse_spine", false)
	--self:setObjectVisible("hongse_spine", false)
	--self:setObjectVisible("bai_spine", false)
	if lv >= 5 and lv < 7 then
		--self:setObjectVisible("zise_spine", true)
		self:setObjectVisible("souch_img", false)
	elseif lv >= 7 and lv < 9 then
		--self:setObjectVisible("jinse_spine", true)
		self:setObjectVisible("souch_img", false)
	elseif lv >= 9 and lv < 11 then
		--self:setObjectVisible("hongse_spine", true)
		self:setObjectVisible("souch_img", false)
	elseif lv >= 11 then
		--self:setObjectVisible("bai_spine", true)
		self:setObjectVisible("souch_img", false)
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
					self:AddAtteNumber("hp_num", last_h, cur_h)
				elseif k == "atk" then
					self:AddAtteNumber("attack_num", last_h, cur_h)
				elseif k == "def" then
					self:AddAtteNumber("def_num", last_h, cur_h)
				end
			else
				if k == "hp" then
					self:setTextByLanKey("hp_num", cur_h)
				elseif k == "atk" then
					self:setTextByLanKey("attack_num", cur_h)
				elseif k == "def" then
					self:setTextByLanKey("def_num", cur_h)
				end
			end
		end
	else
		self:setTextByLanKey("hp_num", attrs["hp"])
		self:setTextByLanKey("attack_num", attrs["atk"])
		self:setTextByLanKey("def_num", attrs["def"])
	end
end

function M:AddAtteNumber(text_name, num1, num2)
	local show_text = self:findText(text_name)
	local text_rt = show_text.gameObject:GetComponent("RectTransform")
	local rect = text_rt.rect
	local num = rect.width

	local add_comb = self:creatEffect("add_attr", show_text.gameObject)
	local combat_text = UIUtil.findText(add_comb.transform)
	combat_text.text = "+"..(num2 - num1)
	local pos_x = (num + 10) * -1
	add_comb.transform.localPosition = Vector3.New(pos_x, 0, 0)
	if self.m_control then
		local function awaitPlay()
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(add_comb.transform:DOLocalMoveX(0, 0.5))
			sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0, 0.5))
			sequence:SetAutoKill(false)
			self.m_control:setOnceTimer(0.5, function()
				if add_comb then
					self.atte_sq[text_name] = self:AttrNumberChange(text_name, num1, num2)
					U3DUtil:Destroy(add_comb)
				end
			end)
		end
		self.m_control:setOnceTimer(0.5, awaitPlay)
	end
end

function M:AttrNumberChange(text_name, num1, num2)
	local sequence = Tweening.DOTween.Sequence()
	sequence:SetAutoKill(false)
	sequence:Append(Tweening.DOTween.To(function(index)
		local temp = math.floor(index)
		self:setText(text_name, temp)
	end, num1, num2, 0.5))
	return sequence
end

function M:creatAttrItem()
	local cell = ResourceUtil:LoadUIGameObject("HeroInfo/HeroAttribute_Cell", Vector3.zero,nil)
	return cell
end

function M:combatZoom()
	local com_parent = self:findGameObject("com")
	local lizi_01 = ResourceUtil:GetUIEffectItem("HeroInfo/UI_HeroInfo_Zhanli_001", com_parent)
	self:setSortingOrder(lizi_01)
	if self.m_control then
		self.m_control:setOnceTimer(0.6, function()
			U3DUtil:Destroy(lizi_01)
		end)
	end
end

function M:lvUpZoom()
	local com_parent = self:findGameObject("hero_effect_parent")
	 local lizi_02 = ResourceUtil:GetUIEffectItem("HeroInfo/UI_HeroInfo_ShengJi_002", com_parent)
	self:setSortingOrder2(lizi_02)
	if self.m_control then
		self.m_control:setOnceTimer(0.6, function()
			U3DUtil:Destroy(lizi_02)
		end)
	end
end

function M:setSortingOrder(obj)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	if LuaBehaviour then
		local Par_liz_1 = LuaBehaviour:FindParticleSystem("fx_hit_01_2")
		local Par_liz_2 = LuaBehaviour:FindParticleSystem("fx_hit_01_3")
		local Par_liz_3 = LuaBehaviour:FindParticleSystem("hylz")
		Par_liz_1:GetComponent("Renderer").sortingOrder = self.m_sortOrder + 1
		Par_liz_2:GetComponent("Renderer").sortingOrder = self.m_sortOrder + 1
		Par_liz_3:GetComponent("Renderer").sortingOrder = self.m_sortOrder + 1
	end
end

function M:setSortingOrder2(obj)
	self:setParticleRenderOrder(obj)
end

function M:attrZoom(atrs)
	local atk_text = self:findGameObject("atk_text")
	local def_text = self:findGameObject("def_text")
	local hp_text = self:findGameObject("hp_text")
	if atrs["atk"] and atrs["atk"] > 0 then
		GameUtil:ZoomObj(atk_text)
	end
	if atrs["def"] and atrs["def"] > 0 then
		GameUtil:ZoomObj(def_text)
	end
	if atrs["hp"] and atrs["hp"] > 0 then
		GameUtil:ZoomObj(hp_text)
	end
end

function M:lvZoom(last_lv, cur_lv)
	if cur_lv > last_lv then
		local lv_text = self:findGameObject("lv_text")
		self:lvUpZoom()
		GameUtil:ZoomObj(lv_text)
	end
end

--[[
    @desc: 英雄升级需要消耗
]]
function M:setLevelUp()
	if self.m_model.m_look_model == 2 then
		return
	end
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

--[[
    @desc: 英雄动画
]]
function M:setSpine()
	if self.m_model:getPoetry() then
		local poet = self.m_model:getPoetry()
		self:setText("poet_text", poet[1])
		self:setText("poet_text2", poet[2])
	end
	local icon = self.m_model:getHeroBigAnim()
	if self.cacheSpineName == icon then
		return
	else
		self.cacheSpineName = icon	
	end
	local pos_x = -8
	local pos_y = -8
	local play_img = self:findGameObject("hero_spine")
 	local sg = play_img:GetComponent("SkeletonGraphic")
	local hehe = ResourceUtil:GetSk(self.cacheSpineName, "rolespine_"..string.lower(self.cacheSpineName))
	sg.skeletonDataAsset = hehe
	sg:Initialize(true)
	local linshi_pos =self.m_model:getSpinePos()
	pos_x = pos_x + linshi_pos[1]
	pos_y = pos_y + linshi_pos[2]
	UIUtil.setLocalPosition(play_img.transform,pos_x, pos_y, 0)
end

--更新装备信息
function M:updateEquipInfo()
	self:refreshRedPoint()
	if self.m_model.m_look_model == 2 then
		return
	end
	local eqp_data = self.m_model:getHeroEquList()
	for k = 1, 4 do
		local data = eqp_data[tostring(k)]
		local luaBehaviour = UIUtil.findLuaBehaviour(self.m_eqps[k])
		if luaBehaviour then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equ_img", false)
			LuaBehaviourUtil.setImg(luaBehaviour, "bg", "a_ws_daojukuang_hui", "hero_ui")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", true)
			if data then
				local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race, data.oid})
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroInfo_ZhuangBei_001", self.m_model:getRace() == data.race)
				local frameData = GlobalConfig.QUALITY_FRAME[itemData.quality].rhomb_frame_name
				if frameData then
					LuaBehaviourUtil.setImg(luaBehaviour, "bg", frameData, "hero_ui")
				end
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
				LuaBehaviourUtil.setImg(luaBehaviour, "equ_img", itemData.icon_name, itemData.atlas_name)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equ_img", true)
				for i = 1, 5 do
					local star = luaBehaviour:FindGameObject("star_" .. i)
					if star then
						star:SetActive(i <= data.lv)
					end
				end
				if data.race ~= 0 then
					local race = GlobalConfig.TYPE_HERO_RACE[data.race].big_race_icon
					LuaBehaviourUtil.setImg(luaBehaviour, "race_img", race, ResourceUtil:getLanAtlas())
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", data.race ~= 0)
				else
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
				end
			else
				for i = 1, 5 do
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_" .. i, false)
				end
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroInfo_ZhuangBei_001", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
			end
		end
	end
	self:playGetEqpEffect()
	self.m_model:detectionEqps()
	self:updateArtifact()
end

--更新神器数据
function M:updateArtifact()
	if self.m_model:checkArtifact() == false then
		local luaBehaviour = UIUtil.findLuaBehaviour(self.m_eqps[5])
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_img", false)
		return
	end
	local art_data, art_cfg = self.m_model:getArtifactData()
	if art_data and art_cfg then
		local luaBehaviour = UIUtil.findLuaBehaviour(self.m_eqps[5])
		local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ARTIFACTS, art_data.id, 1, art_data.oid})
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", true)
		LuaBehaviourUtil.setImg(luaBehaviour, "art_img", itemData.icon_name, itemData.atlas_name)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_img", true)
		--local red_flag = RedPointUtil:checkArtifact(art_data) --神器红点
		local red_point_img = luaBehaviour:FindGameObject("red_point_img")
		--red_point_img:SetActive(red_flag)
	else
		local luaBehaviour = UIUtil.findLuaBehaviour(self.m_eqps[5])
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_img", false)
	end
end

function M:playGetEqpEffect()
	local eqp_list = self.m_model:getHeroEquList()
	local last_list = self.m_model.last_eqps
	for k,v in pairs(eqp_list) do
		local last_eqp = last_list[k]
		if last_eqp == nil or v.id ~= last_eqp.id then
			local ep_name = "eq"..k.."_btn"
			local ep_obj = self:findGameObject(ep_name)
			local tx = ResourceUtil:LoadUIGameObject("HeroInfo/UI_HeroInfo_ZhuangBei_002", Vector3.zero, ep_obj)
			tx.transform.localScale = Vector3(1,1,1)
			self:setParticleRenderOrder(tx)
			if self.m_control then
				self.m_control:setOnceTimer(0.6, function()
					U3DUtil:Destroy(tx)
				end)
			end
		end
	end
end

--更新技能信息
function M:updateSkill()
	local skills = self.m_model:getHeroSkill()
	for i = 1,4 do
		self:setObjectVisible("skill"..i.."_img",false)
		self:setObjectVisible("di_"..i, false)
		self:setObjectVisible("skill_effect_"..i, false)
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
				self:setObjectVisible("skill_effect_"..k, true)
				local lv = self.m_model:getHero_lv()
				local bl = lv < locklv
				self:setObjectVisible(sk_gary_img_name,bl)
			end
		end
	end
end

function M:setGray(bl,img_name)
	local img_obj = self.findImage(img_name)
	if bl == true then
		
	else
		
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

function M:setLock()
	local isLock = self.m_model:getHeroLock()
	self:setObjectVisible("lock_img",isLock)
end

function M:refreshRedPoint()
	if self.m_model.m_look_model == 0 then
		local red_flag = RedPointUtil:checkHeroBetterEquipRedPointById(self.m_model.m_heroid)
		self:setObjectVisible("onekey_equip_red_point_img", red_flag == true)
	else
		self:setObjectVisible("onekey_equip_red_point_img", false)
	end
end

--创建空的装备栏
function M:creatNilEqp(index)
	self.m_eqps = {}
	for i=1,5 do
		local name = "eq"..i.."_btn"
		local icon_node = self:findGameObject(name)
		self.m_eqps[i] = icon_node
	end
end

function M:talk(str)
	if str then
		self.m_talk = self:findGameObject("playerTalk")
		self:setText("talk_Text", Language:getTextByKey(str.lines) )
		self:setObjectVisible("playerTalk", true)
		self.m_control:setOnceTimer(3, handler(self,self.hideTalk))
	end
end

function M:hideTalk()
	self:setObjectVisible("playerTalk", false)
end

function M:getMinAndMax(num)
	local le = #tostring(num) 
	local mom = 1
	for i = 1, le - 1 do
		mom = mom.."0"
	end
	local min = 1 * tonumber(mom)
	mom = mom.."0"
	local max = 1 * tonumber(mom) -1
	return min, max
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

function M:AddCombatNumber(num1, num2)
	local show_text = self:setText("combat_text", GameUtil:formatValueToString(num1))
	local text_rt = show_text.gameObject:GetComponent("RectTransform")
	local rect = text_rt.rect
	local num = rect.width

	local add_comb = self:creatEffect("add_combat", show_text.gameObject)
	local combat_text = UIUtil.findText(add_comb.transform)
	combat_text.text = "+"..(num2 - num1)
	add_comb.transform.localPosition = Vector3.New((num + 20), 0, 0)
	local function awaitPlay()
		if not IsNull(add_comb) then
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(add_comb.transform:DOLocalMoveX(0, 0.5))
			sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0, 0.5))
			sequence:SetAutoKill(false)
			if self.m_control then
				self.m_control:setOnceTimer(0.5, function()
					if not IsNull(add_comb) then
						self.m_sequence = self:NumberChange(num1, num2)
						self:combatZoom()
						self:setText("combat_text", GameUtil:formatValueToString(num2))
						U3DUtil:Destroy(add_comb)
					end
					audio:SendEvtUI("Play_UI_Power_Increase")
				end)
			end			
		end
	end
	self.m_control:setOnceTimer(0.5, awaitPlay)
end

--[[
	对比属性
]]
function M:appendAttrs(last_atttrs, new_attrs)
	local diff_attrs = {}
	for k,v in pairs(new_attrs) do
		if last_atttrs[k] then
			diff_attrs[k] = v - last_atttrs[k]
		else
			diff_attrs[k] = v
		end
	end
	for k,v in pairs(last_atttrs) do
		if new_attrs[k] == nil then
			diff_attrs[k] =  0 - v
		end
	end
	return diff_attrs
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

function M:playAnim( )
	if self.m_luaBehaviour then
		self.m_luaBehaviour:RunAnim("HeroInfo_btn", nil, 1)
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

function M:distoryParticleSystem()
	local com_parent = self:findGameObject("com_show_lizi")
	local com_parent2 = self:findGameObject("hero_spine")
	UIUtil.destroyAllChild(com_parent.transform)
	UIUtil.destroyAllChild(com_parent2.transform)
	if self.eplist then
		for k,v in pairs(self.eplist) do
			if not IsNull(v) then
				U3DUtil:Destroy(v)
			end
		end
	end
end

function M:retainVisibleView()
	self:distoryParticleSystem()
	M.super.retainVisibleView(self)
end

function M:creatEffect(tx_name, prent)
    local item = ResourceUtil:GetUIEffectItem("HeroInfo/"..tx_name, prent)
	--item.transform:SetParent(prent.transform, false)
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


return M