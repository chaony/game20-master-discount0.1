--- 
local M = class("MysticDetailNode",LikeOO.OOUIbase)

M.m_uiName = "Item/MysticDetailNode"

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	self.m_gray_image = self:findImage("gray_image")
	self.m_icon_node = self:findGameObject("icon_node")
	self.m_attr_node = self:findGameObject("attr_node")
	self.m_attrs_node = self:findGameObject("attrs_node")

	self.m_sig_attr_node = self:findGameObject("sig_attr_node") -- 经脉的node
	self.m_cw_propey_node = self:findGameObject("cw_propey") -- 经脉属性总节点

	self.text_jingmai_title = self:findGameObject("text_jingmai_title")
	self:setTextByLanKey("text_jingmai_title", "mystic_detail_tex")
	self:setTextByLanKey("group_skill_title_text", "mystic_str_0057")
	self.attrs_pro = self:findGameObject("attrs_pro")
	self.attrs_pro_fitter = self.attrs_pro:GetComponent("ContentImmediate")
	
end

function M:onButtonClick(obj, name)
	if name == "use_btn" then
		self.m_control:openView("SutraDepository.DepositoryPromotePop") -- 秘籍参悟
	elseif name == "inset_btn" then
		local params = {}
		params.id = self.m_show_data.data_id
		self.m_control:openView("SutraDepository",params ) -- 秘籍镶嵌
	end
	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:refreshUI()
	if self.m_show_data == nil then
		return
	end
	local is_inset = UserDataManager.mystic_data:checkMysticInset(self.m_show_data.data_id)
	self:setObjectVisible("inset_btn", is_inset)
	--UIUtil.setLocalPosition(self.attrs_pro.transform,9999)
	--self.m_control:setOnceTimer(0.1, function ()
	--	if not IsNull(self.attrs_pro) then
	--		UIUtil.setLocalPosition(self.attrs_pro.transform,0)
	--	end
	--end)
	local show_data = self.m_show_data
	--local item_cfg = show_data.item_cfg
	self:setTextByLanKey("common_title_text", show_data.name)
	self:setTextByLanKey("item_des_text", show_data.story)
	self:setTextByLanKey("own_num_text", "new_str_0430", tostring(show_data.user_num))

	self:setTextByLanKey("use_btn_text", "mystic_str_0002")
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)

	local cfg_attrs = show_data.item_cfg.attrs or {}
	local attrs = UserDataManager:appendAttrs(cfg_attrs)
	self:updateLoopScroll(attrs)
	--触发刷新自适应大小
	if self.attrs_pro_fitter then
		self.attrs_pro_fitter:ForceRefreshSize()
	end
	
	local item_cfg = self.m_show_data.item_cfg
	if item_cfg then
		if item_cfg.type == 1 then -- 1 先天 2 绝学
			self:setObjectVisible("zh_desc", false) -- 屏蔽技能相关
			self:setObjectVisible("cw_propey", true)
		else
			self:setObjectVisible("cw_propey", false) -- 屏蔽技能相关
			self:setObjectVisible("zh_desc", true)
		end
		self:updateChannelAttrLoopScroll()
		self:refreshSkillDetail()

		if item_cfg.mystic_score and item_cfg.mystic_score > 0 then
			self:setObjectVisible("combat_num_text", true)
			self:setTextByLanKey("combat_num_text", Language:getTextByKey("new_str_0678")..":"..GameUtil:formatValueToString(item_cfg.mystic_score))
		else
			self:setObjectVisible("combat_num_text", false)
		end
	end
	
end

function M:updateView(data)
	self.m_show_data = data
	self:refreshUI()
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "mystices_update" then
		self:refreshUI()
	end
end

--[[	
	属性列表
]]
function M:updateLoopScroll(attrs)
	local data = {}
	for i, v in pairs(attrs) do
		table.insert(data, {i, v})
	end
	UIUtil.destroyAllChild(self.m_attrs_node.transform)
	for k,cell_data in ipairs(data) do
		local cell_object = GameUtil:instanceObject(self.m_attr_node, self.m_attrs_node.transform)
		cell_object:SetActive(true)
		local cp = GameUtil:getAttrsName(cell_data[1])
		local transform = cell_object.transform
		local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text")
		-- 四舍五入保留小数点后一位
		local attr_value = cell_data[2] or 0
		attr_value = math.floor(attr_value * 10 + 0.5)/10
		local attr_value_text = nil
		if GameUtil:attrTransition(cell_data[1]) == true then
			attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value).."%", "attr_value_text")
		else
			attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value), "attr_value_text")
		end

		local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
		UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
		UIUtil.setObjectVisible(transform, false, "attr_add_value_text")
	end
end

-- 刷新经脉属性
function M:updateChannelAttrLoopScroll()
	local data = self:getChannelAttr()
	if data and #data == 0 then
		self.text_jingmai_title:SetActive(false)
	end
	UIUtil.destroyAllChild(self.m_cw_propey_node.transform)
	for k,cell_data in ipairs(data) do
		local cell_object = GameUtil:instanceObject(self.m_sig_attr_node, self.m_cw_propey_node.transform)
		cell_object:SetActive(true)
		local transform = cell_object.transform
		local attr = cell_data.attr
		local attr_cfg = GameUtil:getAttrCfg(attr[1])
		--UIUtil.setTextByLanKey(transform, "type_text", Language:getTextByKey(attr_cfg.name) .. ":")
		local value = Language:getTextByKey(attr_cfg.name) .."：+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2]))
		if cell_data.open then
			UIUtil.setTextByLanKey(transform, "vein_desc", value)
		else
			local global_cfg = GlobalConfig.TYPE_MERIDIAN_OLD[cell_data.meridian_type]
			UIUtil.setTextByLanKey(transform, "vein_desc", "mystic_str_0047", value, Language:getTextByKey(global_cfg.name), cell_data.channel_lv,cell_data.lv)
			UIUtil.setTextColor(transform, Color( 145/255, 145/255, 145/255), "vein_desc")
			UIUtil.setTextColor(transform, Color( 145/255, 145/255, 145/255), "type_text")
		end
	end
	
end

function M:getChannelAttr()
	local show_data = {}
	local mystic_cfg = self.m_show_data.item_cfg
	for i, v in pairs(mystic_cfg.meridian) do
		local channel_lv = 0
		local activation = v.activation
		for m = 1, #activation do
			show_data[#show_data + 1] = {lv = activation[m],channel_lv = channel_lv, attr = v.attr[m], mystic_type = mystic_cfg.type, open = channel_lv >= activation[m], meridian_type = i }
		end
	end
	return show_data
end

function M:refreshSkillDetail()
	local cfg = self:getMysticData()
	local group_cfg = self:getMysticBuffGroup()
	if table.nums(group_cfg) > 0 then
		local mysticCfg = group_cfg[1] or {} -- 先默认选第一个，未来可能要展示一本秘籍的多个技能(目前界面不允许这样显示)
		self:setTextByLanKey("aomi_name", mysticCfg.name)
		self:setTextByLanKey("propey_name", mysticCfg.des)
		self:setImg( mysticCfg.icon,"skill_icon","group_skill_img")
		local buff_id = cfg.buff or {}
		--self:setObjectVisible("zh_desc", #buff_id > 0)
		self:setObjectVisible("zh_desc", true)

		if mysticCfg then
			local des_text = Language:getTextByKey(mysticCfg.des).."\n"..Language:getTextByKey(mysticCfg.des_class)
			--self:setTextByLanKey("skill_detail_text", Language:getTextByKey(group_cfg[1].des))
			self:setTextByLanKey("skill_detail_text", des_text)
		end

		self:setObjectVisible("group_lock_img", false)
		self:setObjectVisible("group_skill_img", true)
		local group_skill_img_com = self:findImage("group_skill_img")
		group_skill_img_com.material = nil
	else
		self:setObjectVisible("zh_desc", false)
	end
end

function M:getMysticData()
	local cfg = nil
	if self.m_show_data then
		cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_show_data.data_id)
	end
	return cfg
end

function M:getMysticBuffGroup()
	local buff_group_cfg = {}
	local cfg = self:getMysticData()
	if cfg then
		local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
		local buff = UserDataManager.mystic_data:getMysticEfficientSkill(self.m_show_data.data_id)
		for i, v in pairs(buff) do
			buff_group_cfg[i] = mystic_buff_cfg[v]
		end
	end
	return buff_group_cfg
end



function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M