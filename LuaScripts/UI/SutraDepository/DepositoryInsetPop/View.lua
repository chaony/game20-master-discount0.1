local M = class("MeridianListView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "SutraDepository/DepositoryInsetPop"

local __TAB_BTN_NODE = {
	{btn_key = "all_togglebtn", lua_name = "", btn_text = "all_btn_text", text_key = "new_str_0044", open = true}, -- 全部
	{btn_key = "tian_togglebtn", lua_name = "", btn_text = "tian_btn_text", text_key = "mystic_str_0056", open = true,}, -- 先天
	{btn_key = "jue_togglebtn", lua_name = "", btn_text = "jue_btn_text", text_key = "mystic_str_0057", open = true}, -- 绝学
	{btn_key = "shen_togglebtn", lua_name = "", btn_text = "shen_btn_text", text_key = "mystic_str_0085", open = true, season = 4}, -- 神技
}

function M:onEnter()
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, Language:getTextByKey(v.text_key))
		local tog_btn = self:findToggle(v.btn_key)
		if v.season then
			local season = UserDataManager:getCurSeason()
			v.open = season >= v.season
		end

		tog_btn.gameObject:SetActive(v.open)
		local cur_tab_text = self:findText(v.btn_text)
		if k == self.m_model.m_sel_tab_index then
			tog_btn.isOn = true
		end
		cur_tab_text.color = self.m_model.m_sel_tab_index == k and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
	end
	
	self.m_center = self:findGameObject("center")
	self:setObjectVisible("nil_bg_img",false)
	self:setObjectVisible("have_bg_img",false)
	self:setObjectVisible("cur_equip",false)
	self:setObjectVisible("nil_eqp",false)
	self:setObjectVisible("vocation_type_img",false)
	if self.m_model.m_mystic_data then
		self:setCurMystic()
		self:setObjectVisible("cur_equip",true)
		self:setObjectVisible("have_bg_img",true)
	else
		self:setObjectVisible("nil_caneqp",true)
	end
	self:setTextByLanKey("nil_caneqp_text","mystic_str_0093")
	self:updateLoopScroll()

	self:setTextByLanKey("common_title_text", "mystic_str_0089")
	self:setTextByLanKey("common_no_have_text", "new_str_0737")
	
	self:setTextByLanKey("add_attr_des_text", "mystic_str_0045")
	self.text_jingmai_title = self:findGameObject("text_jingmai_title")
	self.m_attr_node = self:findGameObject("attr_node") -- 基础属性的node
	self.m_attrs_node = self:findGameObject("attrs_node") -- 基础属性总节点
	self.m_sig_attr_node = self:findGameObject("sig_attr_node") -- 经脉的node
	self.m_cw_propey_node = self:findGameObject("cw_propey") -- 经脉属性总节点
	local attrs_pro = self:findGameObject("attrs_pro")
	
	self:setObjectVisible("aomi_node", self.m_model.m_mystic_type == 2 or self.m_model.m_mystic_type == 3 ) -- 1 先天 2 绝学
	local str = "mystic_str_0046" 
	if self.m_model.m_mystic_type == 2 or self.m_model.m_mystic_type == 3  then
		str = "mystic_str_0068"
	end
	self:setTextByLanKey("text_jingmai_title", str)
	self:creatSkillIcon() -- 创建技能图标
	self:updateBaseAttrLoopScroll() -- 基础属性刷新
	self:updateChannelAttrLoopScroll() -- 经脉属性刷新
	local attrs_pro_fitter = attrs_pro:GetComponent("ContentImmediate")
	attrs_pro_fitter:ForceRefreshSize()--触发刷新自适应大小
end

-- 筛选标签点击事件
function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:switchTabNode(index, keep_offset)
	for k,v in pairs(__TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
	end
	self:updateLoopScroll()
end

function M:setCurMystic()
	local data, cfg = self.m_model.m_mystic_data, self.m_model.m_mystic_cfg
	self:setObjectVisible("cur_equip",true)
	self.m_icon_node = self:findGameObject("equ_parent")
	if cfg then
		if data then
			local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, data.id, 0}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
			GameUtil:updateItemEquipInfo(go, data)
			local type_meridian = GlobalConfig.TYPE_MERIDIAN[cfg.type]
			self:setImg(type_meridian.pro_icon, ResourceUtil:getLanAtlas(), "cur_type_img")
			local vocation_meridian = GlobalConfig.CLASS_MERIDIAN[cfg.role_type]
			local a_atlas = ResourceUtil:getLanAtlas()
			if vocation_meridian ~= nil and vocation_meridian ~= 0 then
				self:setImg(vocation_meridian.pro_icon, ResourceUtil:getLanAtlas(), "vocation_type_img")
				self:setObjectVisible("vocation_type_img",true)
			end
			--self:setTextByLanKey("cureqp_combat_text", self.m_model:getCurEqpCombat())
			--self:setObjectVisible("cur_equip_star_node",false)
		else
			local go = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.MYSTIC, cfg.id, 0}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
		end
		self:setTextByLanKey("cureqp_text", cfg.name)
		local color = GlobalConfig.QUALITY_COMMON_SETTING[cfg.quality]
		self:setTextColor("cureqp_text", color.RGBA)
		local type_data = GlobalConfig.TYPE_MYSTIC[cfg.type]
		if type_data then
			self:setImg(type_data.pro_icon, ResourceUtil:getLanAtlas(), "cur_type_img")
		end
		local vocation_data = GlobalConfig.CLASS_MERIDIAN[cfg.role_type]
		if vocation_data and vocation_data ~= 0 then
			self:setImg(vocation_data.pro_icon, ResourceUtil:getLanAtlas(), "vocation_type_img")
			self:setObjectVisible("vocation_type_img",true)
		end
	end
end

function M:updateLoopScroll()
	local data = self.m_model:getShowList()
	self:setObjectVisible("CommonTipsNode",  #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:setEqpInfo(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "replace_btn" then
					self:updateMsg("replace_equip", cell_data)
				elseif click_name == "check_btn" then
					self:updateMsg("wear_equip", cell_data)
				elseif click_name == "group_list_detail_btn" then
					self:updateMsg("group_list_detail_btn", cell_data)
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:setEqpInfo(obj, eqp_data)
	local eqp_cfg = UserDataManager.mystic_data:getMysticConfigByCid(eqp_data.mystic.id)
	if obj == nil or eqp_data ==nil or eqp_cfg == nil then 
		Logger.log("<color=red>Error setEqpInfo  Is Nil </color>")
		return 
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local m_icon_node = UIUtil.findTrans(obj.transform, "itemParent")
	UIUtil.destroyAllChild(m_icon_node)
	if eqp_cfg then
		if eqp_data then
			local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, eqp_data.mystic.id, 0}, false, false, function()
				self:updateMsg("loop_depository", {oid = eqp_data.mystic.id, look_model = 2})
			end)
			go.transform:SetParent(m_icon_node, false)
			GameUtil:updateItemEquipInfo(go, eqp_data.mystic)
			local type_meridian = GlobalConfig.TYPE_MERIDIAN[eqp_cfg.type]
			LuaBehaviourUtil.setImg(luaBehaviour, "camp_img2", type_meridian.pro_icon,  ResourceUtil:getLanAtlas())
			local class_meridian = GlobalConfig.CLASS_MERIDIAN[eqp_cfg.role_type or 0] or 0
			if class_meridian == 0 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",false)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",true)
				LuaBehaviourUtil.setImg(luaBehaviour, "vocation_img", class_meridian.pro_icon,  ResourceUtil:getLanAtlas())
			end
		else
			local go = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.MYSTIC, eqp_cfg.id, 0}, false, false)
			go.transform:SetParent(m_icon_node, false)
		end
	end
	local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[eqp_cfg.quality]
	if luaBehaviour then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn_tuijian", false)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "check_btn_text", "mystic_str_0090")
		local name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name_text", eqp_cfg.name) --装备名字
		local mystic_attrs = UserDataManager:getOneMysticAttrs(eqp_data.mystic, eqp_cfg)
		local all_attrs = UserDataManager:appendCfgAttrs(mystic_attrs)

		--local base_attrs = hero_data.attrs
		--local attrs = UserDataManager:getAddHeroAttrs(all_attrs, base_attrs)
		--local combat = UserDataManager:computeEquipCombat(attrs)  
		
		
		LuaBehaviourUtil.setImg(luaBehaviour,"icon_img",eqp_cfg.icon,"equip_icon")--装备Icon
		LuaBehaviourUtil.setImg(luaBehaviour,"kuang_img", quality_item.frame_name, "equip_icon")--装备外框
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "group_icon", false)
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_bg", false)
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
		name_text.color = quality_item.RGBA
		local owner = eqp_data.owner or ""
		local type_data = GlobalConfig.TYPE_MYSTIC[eqp_cfg.type]
		if type_data then
			LuaBehaviourUtil.setImg(luaBehaviour, "type_img", type_data.pro_icon,  ResourceUtil:getLanAtlas())
		end
		if self.m_model.m_oid then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "replace_btn", true)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "replace_btn", false)
		end
		if #owner > 0 then --是否是已被其他人装备的
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "owner_obj", true)
			
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "replace_btn_tuijian", false)
			local data = UserDataManager.hero_data:getHeroDataById(owner)
			if data then
				local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, data.oid})
				LuaBehaviourUtil.setImg(luaBehaviour, "card_img", reward_data.icon_name, reward_data.atlas_name)
			end
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "owner_obj", false)
		end
		GameUtil:updateMysticInfo(obj, eqp_data.mystic)

		-- 秘籍属性
		local attrs_pro = luaBehaviour:FindGameObject("item_attrs_pro")
		local attrs_node = luaBehaviour:FindGameObject("item_attrs_node")
		local attr_node = luaBehaviour:FindGameObject("item_attr_node")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "item_aomi_node", eqp_cfg.type == 2 or eqp_cfg.type == 3 ) -- 1 先天 2 绝学
		local attrs = self.m_model:getMysticAllAttr(eqp_cfg)
		self:updateAttrLoopScroll(attrs, attrs_node, attr_node)
		-- 秘籍技能
		local group_cfg = self.m_model:getMysticBuffGroupById(eqp_data.mystic.id)
		if table.nums(group_cfg) > 0 then
			local mysticCfg = group_cfg[1] or {} -- 先默认选第一个，未来可能要展示一本秘籍的多个技能(目前界面不允许这样显示)
			LuaBehaviourUtil.setImg(luaBehaviour,"item_group_skill_img", mysticCfg.icon, "skill_icon")
		end
		local attrs_pro_fitter = attrs_pro:GetComponent("ContentImmediate")
		attrs_pro_fitter:ForceRefreshSize()--触发刷新自适应大小
	end
end

--[[	
	基础属性列表
]]
function M:updateBaseAttrLoopScroll()
	local data = self.m_model:getFormatMysticBaseAttr() -- 获取基础属性
	UIUtil.destroyAllChild(self.m_attrs_node.transform)
	for k,cell_data in ipairs(data) do
		local cell_object = GameUtil:instanceObject(self.m_attr_node, self.m_attrs_node.transform)
		cell_object:SetActive(true)
		local transform = cell_object.transform
		for i = 1, 2 do
			if cell_data[i] then
				local attr = cell_data[i]
				local cp = GameUtil:getAttrsName(attr[1]) .. ":"
				local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text"..i)
				-- 四舍五入保留小数点后一位
				local attr_value = attr[2] or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				local attr_value_text = nil
				if GameUtil:attrTransition(attr[1]) == true then
					attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "attr_value_text"..i)
				else
					attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value), "attr_value_text"..i)
				end

				local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
				UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
			else
				UIUtil.setText(transform, "", "attr_name_text"..i)
				UIUtil.setText(transform, "", "attr_value_text"..i)
			end
		end
	end
end

-- 刷新经脉属性
function M:updateChannelAttrLoopScroll()
	local data = self.m_model:getFormatMysticSigAttr()
	if data and #data == 0 and self.m_model.m_mystic_type == 1 then
		self.text_jingmai_title:SetActive(false)
	end
	UIUtil.destroyAllChild(self.m_cw_propey_node.transform)
	for k,cell_data in ipairs(data) do
		local cell_object = GameUtil:instanceObject(self.m_sig_attr_node, self.m_cw_propey_node.transform)
		cell_object:SetActive(true)
		local transform = cell_object.transform
		for i = 1, 2 do
			if cell_data[i] then
				local attr = cell_data[i]
				local cp = GameUtil:getAttrsName(attr[1]) .. ":"
				local attr_name_text = UIUtil.setText(transform, cp, "type_text"..i)
				-- 四舍五入保留小数点后一位
				local attr_value = attr[2] or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				local attr_value_text = nil
				if GameUtil:attrTransition(attr[1]) == true then
					attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "vein_desc"..i)
				else
					attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value), "vein_desc"..i)
				end

				local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
				UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
			else
				UIUtil.setTextByLanKey(transform, "type_text"..i, "")
				UIUtil.setTextByLanKey(transform, "vein_desc"..i, "")
			end
		end
	end

end

-- 创建技能图标
function M:creatSkillIcon()
	if self.m_model.m_mystic_data then
		local group_cfg = self.m_model:getMysticBuffGroupById(self.m_model.m_mystic_data.id)
		if group_cfg and table.nums(group_cfg) > 0 then
			local group_skill_title_text = self:findText("group_skill_title_text")
			local mysticCfg = group_cfg[1] or {} -- 先默认选第一个，未来可能要展示一本秘籍的多个技能(目前界面不允许这样显示)
			group_skill_title_text.text = Language:getTextByKey(mysticCfg.name)
			self:setImg( mysticCfg.icon,"skill_icon","group_skill_img")
		end
	end
end

-- 刷新右侧列表的属性
function M:updateAttrLoopScroll(attrs, attrs_node, attr_node)
	UIUtil.destroyAllChild(attrs_node.transform) -- 移除所有子节点
	if not attrs then return end
	for k,cell_data in ipairs(attrs) do
		local cell_object = GameUtil:instanceObject(attr_node, attrs_node.transform)
		cell_object:SetActive(true)
		for i = 1, 2 do
			local transform = cell_object.transform
			if cell_data[i] then
				local cp = GameUtil:getAttrsName(cell_data[i][1])
				local attr_name_text = UIUtil.setText(transform, cp, "item_attr_name"..i)
				-- 四舍五入保留小数点后一位
				local attr_value = cell_data[i][2] or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				local attr_value_text = nil
				if GameUtil:attrTransition(cell_data[i][1]) == true then
					attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "item_attr_value"..i)
				else
					attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value), "item_attr_value"..i)
				end
				local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
				UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
			else
				UIUtil.setText(transform, "", "item_attr_name"..i)
				UIUtil.setText(transform, "", "item_attr_value"..i)
			end
		end
	end
end


return M