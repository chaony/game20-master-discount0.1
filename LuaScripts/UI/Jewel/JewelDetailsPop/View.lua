local M = class("JewelDetailsPopView",LikeOO.OOPopBase)

M.m_uiName = "Jewel/JewelDetailsPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("common_title_text", "jewel_text_003")
	self:setTextByLanKey("attr_title_text", "jewel_text_005")
	self:setTextByLanKey("privilege_title_text", "jewel_text_006")
	self:setTextByLanKey("friendship_title_text", "jewel_text_007")
	self:setTextByLanKey("hero_title_text", "jewel_text_008")
	self:setTextByLanKey("upgrade_btn_text", "jewel_text_004")
	self:setTextByLanKey("awaken_btn_text", "jewel_text_009")
	self:setTextByLanKey("hero_title_text2", "jewel_text_012")
	self:setObjectVisible("effect", false)
	self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
end

function M:refreshUI()
	local jewel = self.m_model.m_jewel
	local cfg = self.m_model.m_jewel_cfg
	--icon & name
	local icon_img = self:findImage("icon_img")
	local names = string.split(cfg.icon, "_")
	local icon_id = names[#names]
	GameUtil:updateResourcesImg(icon_img, "Texture/jewelIcon/jewel_" .. icon_id)
	local name_text = self:setText("jewel_name_text", Language:getTextByKey(cfg.name))
	local quality_cfg = GameUtil:getHeroQualityData(cfg.quality)
	name_text.color = quality_cfg.RGBA
	--hero icon
	local is_hero = cfg.hero_id and cfg.hero_id > 0 --专属侠客秘宝
	if is_hero == true then
		self:setObjectVisible("hero_only", true)
		local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cfg.hero_id)
		self:setImg(hero_cfg.icon, "hero_head_ui", "tx_img")
		self:setText("hero_name_text", Language:getTextByKey(hero_cfg.name))
	else
		self:setObjectVisible("hero_only", false)
	end
	--evo & awaken
	--当前属性，下级属性，是否可以觉醒
	local cur_cfg, next_cfg, state = self.m_model:getCfg(jewel.id, jewel.evo, jewel.awaken)
	local is_awakened = state == 2 --已觉醒
	if is_awakened == true then
		self:setObjectVisible("btn_node", false)
		self:setObjectVisible("awaken_img", true)
		self:setObjectVisible("jewel_stars", false)
	else
		self:setObjectVisible("btn_node", true)
		self:setObjectVisible("awaken_img", false)
		self:setObjectVisible("jewel_stars", true)
		local quality_cfg = GameUtil:getHeroQualityData(cfg.quality)
		local star = self.m_model.m_jewel.evo
		local star_max = 5
		for i = 1, 5 do
			local star_ui_name = "jewel_star_" .. i
			if i > star_max then
				self:setObjectVisible(star_ui_name, false)
			else
				if i <= star then
					self:setObjectVisible(star_ui_name, true)
					self:setImg(quality_cfg.star_frame_name, "hero_head_ui", star_ui_name)
				else
					self:setObjectVisible(star_ui_name, false)
				end
			end
		end
		--升星&觉醒消耗
		if state == 1 then
			self:setObjectVisible("upgrade_btn", false)
			self:setObjectVisible("awaken_btn", true)
		else
			self:setObjectVisible("upgrade_btn", true)
			self:setObjectVisible("awaken_btn", false)
		end
		local costs = next_cfg.costs
		local cost_node = self:findGameObject("cost_list")
		UIUtil.destroyAllChild(cost_node.transform)
		local item = GameUtil:createRewards(cost_node.transform, costs, true, true, nil, 1)
		for k,v in ipairs(item) do
			local cost = costs[k]
			local item_luaBehaviour = UIUtil.findLuaBehaviour(v)
			local cost_item = RewardUtil:getProcessRewardData(cost)
			if cost_item.user_num < cost_item.data_num then
				LuaBehaviourUtil.setTextByLanKey(item_luaBehaviour,"count_text","jewel_text_017", tostring(cost_item.user_num), tostring(cost_item.data_num))
			else
				LuaBehaviourUtil.setTextByLanKey(item_luaBehaviour,"count_text", tostring(cost_item.user_num) .. "/" .. tostring(cost_item.data_num))
			end
		end
	end
	--计算战力
	local combat = self.m_model:getCombat(cur_cfg)
	self:setText("combat_text", combat)
	--属性加成
	local attrs = self.m_model:getAttrs(cur_cfg.attrs, next_cfg and next_cfg.attrs or nil)
	self:refreshAttrs(attrs, is_hero, state == 1)
	if next_cfg ~= nil then
		self:refreshEffect(attrs, is_hero, combat, self.m_model:getCombat(next_cfg)) --
	end
	--羁绊宝物
	self:refreshFriendship(cfg)
	--专属强化 & 特权加成
	self:setObjectVisible("hero_node", false)
	self:setObjectVisible("privilege_node", false)
	if is_hero == true then
		self:refreshHeroOnly(cur_cfg, next_cfg, state == 1)--专属强化
	else
		self:refreshPrivilege(cur_cfg, next_cfg, state == 1)--特权加成
	end
end

function M:refreshAttrs(attrs, is_hero, is_can_awaken)
	for i = 1, 4 do
		local attr = attrs[i]
		local obj = self:findGameObject("attr_node_" .. i)
		if attr == nil then
			obj:SetActive(false)
		else
			obj:SetActive(true)
			local luaBehaviour = UIUtil.findLuaBehaviour(obj)
			local attr_name = UserDataManager:getNewAttrsNameByAttrId(attr.id)
			local prefix = Language:getTextByKey(is_hero == true and "jewel_text_011" or "jewel_text_010") --全体 & 专属侠客
			LuaBehaviourUtil.setText(luaBehaviour, "name_text", prefix .. attr_name)
			-- 四舍五入保留小数点后一位
			local attr_value = attr.value or 0
			attr_value = math.floor(attr_value * 100 + 0.5) / 100
			local attr_add_value = attr.add_value or 0
			attr_add_value = math.floor(attr_add_value * 100 + 0.5) / 100
			prefix = Language:getTextByKey(is_can_awaken == true and "jewel_text_009" or "jewel_text_004") .. "+" --觉醒 & 升星
			if GameUtil:newAttrTransition(attr.id) == true then
				LuaBehaviourUtil.setText(luaBehaviour, "value_text", "+" .. GameUtil:formatNum(attr_value) .. "%")
				if attr_add_value > 0 then
					LuaBehaviourUtil.setText(luaBehaviour, "add_value_text", "(" .. prefix .. GameUtil:formatNum(attr_add_value) .. "%)")
				else
					LuaBehaviourUtil.setText(luaBehaviour, "add_value_text", "")
				end
			else
				LuaBehaviourUtil.setText(luaBehaviour, "value_text", "+" .. GameUtil:formatNum(attr_value))
				if attr_add_value > 0 then
					LuaBehaviourUtil.setText(luaBehaviour, "add_value_text", "(" .. prefix .. GameUtil:formatNum(attr_add_value) .. ")")
				else
					LuaBehaviourUtil.setText(luaBehaviour, "add_value_text", "")
				end
			end
		end
	end
end

function M:refreshFriendship(cfg)
	if not(cfg.suit_id and cfg.suit_id > 0) then
		self:setObjectVisible("friendship_node", false)
		return
	end
	local suit_tab = ConfigManager:getCfgByName("jewel_suit")
	local suit_cfg = suit_tab[cfg.suit_id]
	self:setObjectVisible("friendship_node", true)
	for i = 1, 6 do
		local suit_jewel_id = suit_cfg.jewels[i]
		if suit_jewel_id then
			local jewel_cfg = self.m_model:getJewelCfg(suit_jewel_id)
			--local icon_img = self:setImg(jewel_cfg.icon, "jewel_ui", "icon_img_" .. i)
			local icon_img = self:findImage("icon_img_" .. i)
			GameUtil:updateResourcesImg(icon_img, "Texture/jewelIcon/" .. jewel_cfg.icon)
			icon_img:SetActive(true)
			local is_active = self.m_model:checkActive(suit_jewel_id)
			icon_img.material = is_active == true and nil or self.gray_img.material
		else
			self:setObjectVisible("icon_img_" .. i, false)
		end
	end
	self:setTextByLanKey("friendship_text", "")
end

function M:refreshPrivilege(cur_cfg, next_cfg, is_can_awaken)
	if cur_cfg.effect and cur_cfg.effect > 0 then
		local icon_name, cur_desc, next_desc = self.m_model:getPrivilege(cur_cfg.effect, next_cfg and next_cfg.effect or nil)
		self:setObjectVisible("privilege_node", true)
		if icon_name == nil or icon_name == "" then
			self:setObjectVisible("privilege_icon_bg", false)
		else
			self:setObjectVisible("privilege_icon_bg", true)
			self:setImg(icon_name, "skill_icon", "privilege_icon")
		end
		local prefix = Language:getTextByKey(is_can_awaken == true and "jewel_text_009" or "jewel_text_004") .. "  " --觉醒 & 升星
		local desc = cur_desc
		if next_desc ~= nil then
			desc = desc .. "  <color=#3D740D>(" .. prefix .. next_desc .. ")</color>"
		end
		self:setTextByLanKey("privilege_text", desc)
	else
		self:setObjectVisible("privilege_node", false)
	end
end

function M:refreshHeroOnly(cur_cfg, next_cfg, is_can_awaken)
	if cur_cfg.effect and cur_cfg.effect > 0 then
		local icon_name, cur_desc, next_desc = self.m_model:getPrivilege(cur_cfg.effect, next_cfg and next_cfg.effect or nil)
		self:setObjectVisible("hero_node", true)
		if icon_name == nil or icon_name == "" then
			self:setObjectVisible("hero_skill_bg", false)
		else
			self:setObjectVisible("hero_skill_bg", true)
			self:setImg(icon_name, "skill_icon", "hero_skill_icon")
		end
		local prefix = Language:getTextByKey(is_can_awaken == true and "jewel_text_009" or "jewel_text_004") .. "  " --觉醒 & 升星
		local desc = cur_desc
		if next_desc ~= nil then
			desc = desc .. "  <color=#3D740D>(" .. prefix .. next_desc .. ")</color>"
		end
		self:setTextByLanKey("hero_text", desc)
	else
		self:setObjectVisible("hero_node", false)
	end
end

function M:playEffect(is_awaken)
	self:setObjectVisible("effect", true)
	local text_name = is_awaken == true and "a_jewel_juexingchenggong" or "a_jewel_shengxingchenggong"
	self:setImg(text_name, "language_zh_cn", "effect_text_img")
	--local function callback()
	--	self:setObjectVisible("effect", false)
	--end
	--self.m_control:setOnceTimer(2, callback)
end

function M:closeEffect()
	self:setObjectVisible("effect", false)
end

function M:refreshEffect(attrs, is_hero, combat, new_combat)
	for i = 1, 4 do
		local attr = attrs[i]
		local obj = self:findGameObject("attrs_" .. i)
		if attr == nil then
			obj:SetActive(false)
		else
			obj:SetActive(true)
			local luaBehaviour = UIUtil.findLuaBehaviour(obj)
			local attr_name = UserDataManager:getNewAttrsNameByAttrId(attr.id)
			local prefix = Language:getTextByKey(is_hero == true and "jewel_text_011" or "jewel_text_010") --全体 & 专属侠客
			LuaBehaviourUtil.setText(luaBehaviour, "name_text", prefix .. attr_name)
			-- 四舍五入保留小数点后一位
			local attr_value = attr.value or 0
			attr_value = math.floor(attr_value * 100 + 0.5) / 100
			local attr_add_value = attr.add_value or 0
			attr_add_value = math.floor(attr_add_value * 100 + 0.5) / 100
			--prefix = Language:getTextByKey(is_can_awaken == true and "jewel_text_009" or "jewel_text_004") .. "+" --觉醒 & 升星
			if GameUtil:newAttrTransition(attr.id) == true then
				LuaBehaviourUtil.setText(luaBehaviour, "value_text", GameUtil:formatNum(attr_value) .. "%")
				if attr_add_value > 0 then
					LuaBehaviourUtil.setText(luaBehaviour, "value_new_text", GameUtil:formatNum(attr_add_value) .. "%")
				else
					LuaBehaviourUtil.setText(luaBehaviour, "value_new_text", "")
				end
			else
				LuaBehaviourUtil.setText(luaBehaviour, "value_text", GameUtil:formatNum(attr_value))
				if attr_add_value > 0 then
					LuaBehaviourUtil.setText(luaBehaviour, "value_new_text", GameUtil:formatNum(attr_add_value))
				else
					LuaBehaviourUtil.setText(luaBehaviour, "value_new_text", "")
				end
			end
		end
	end
	local obj = self:findGameObject("attrs_combat")
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", "new_str_0490")
	LuaBehaviourUtil.setText(luaBehaviour, "value_text", combat)
	LuaBehaviourUtil.setText(luaBehaviour, "value_new_text", new_combat)
end

return M