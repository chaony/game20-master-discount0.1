--- 
local M = class("ItemEquipNode",LikeOO.OOUIbase)

M.m_uiName = "Item/ItemEquipNode"

function M:onEnter()
	self:setTextByLanKey("combat_title_text", "friend_str_0041")
	self:setTextByLanKey("type_title_text", "new_str_0641")
	self.m_icon_node = self:findGameObject("icon_node")
	self.m_attr_node = self:findGameObject("attr_node")
	self.m_attrs_node = self:findGameObject("attrs_node")
	self.affix_attrs_node = self:findGameObject("affix_attrs_node")
	self.eqp_pro = self:findGameObject("eqp_pro")
	self.eqp_pro_fitter = self.eqp_pro:GetComponent("ContentImmediate")
end

function M:onButtonClick(obj, name)
	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:refreshUI()
	if self.m_show_data == nil then
		return
	end
	UIUtil.setLocalPosition(self.eqp_pro.transform,9999)
	self.m_control:setOnceTimer(0.1, function ()
		if not IsNull(self.eqp_pro) then
			UIUtil.setLocalPosition(self.eqp_pro.transform,160)
		end
	end)
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	self:setTextByLanKey("common_title_text", show_data.name)
	self:setTextByLanKey("name_text", "new_str_0429", Language:getTextByKey(item_cfg.type_name or ""))
	self:setTextByLanKey("item_des_text", show_data.story)
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)
	self:setObjectVisible("race_img", false)

	local type_icon = GlobalConfig.TYPE_HERO_PROPERTY[item_cfg.type]
	self:setImg(type_icon.pro_icon,"hero_ui","type_img") --装备属性类型图标
	self:setTextByLanKey("type_text", type_icon.name)
	local equip_data = UserDataManager.equip_data:getEquipDataById(self.m_show_data.oid)
	local race_add_str = ""
	if equip_data then
		local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(equip_data, item_cfg))
		local affix_attrs, affix_ts = self:getPolishedAttrs(equip_data, item_cfg)
		local affix_atr = {}
		if affix_attrs and next(affix_attrs) then
			for i = 1, #affix_attrs do
				local cur_data = affix_attrs[i]
				local affix_data = cur_data.data
				local affix_cfg = cur_data.cfg
				if affix_data then
					local attr = affix_data.value[1]
					if next(attr) ~= nil then
						local atk_key = GameUtil:getAttrsKey(attr[2])
						affix_atr[atk_key] = attr[3]
					 end
				end	 
			end
			self:setObjectVisible("line_affix",true)
			self:setObjectVisible("affix_attrs_node",true)	
		else
			self:setObjectVisible("line_affix",false)
			self:setObjectVisible("affix_attrs_node",false)	
		end
		self:updateLoopScroll(attrs)
		self:updateAffixLoopScroll(affix_atr)
		local combat = UserDataManager:computeEquipCombat(attrs)
		if affix_attrs and next(affix_attrs) then
			--local affix_combat = UserDataManager:getEquipAffixCombat(equip_data)
			combat = math.ceil(combat)
		end
		self:setTextByLanKey("combat_text", combat)
		-- 种族加成
		local race = equip_data.race or 0
		local race_value = ConfigManager:getCommonValueById(45, 0)
		if affix_ts and affix_ts.cfg then
			race_add_str = Language:getTextByKey(affix_ts.cfg.affix_des)
		end
		if race > 0 then
			local race_item = GlobalConfig.TYPE_HERO_RACE[race]
			if race_item then
				if affix_ts and affix_ts.cfg then
					race_add_str = race_add_str.."\n\n"..Language:getTextByKey("new_str_0642", Language:getTextByKey(race_item.name), race_value)
				else
					race_add_str = Language:getTextByKey("new_str_0642", Language:getTextByKey(race_item.name), race_value)
				end
			end
		end
	end
	self:setTextByLanKey("add_attr_des_text", race_add_str)
	--触发刷新自适应大小
	if self.eqp_pro_fitter then
		self.eqp_pro_fitter:ForceRefreshSize()
	end
end

function M:updateView(data)
	self.m_show_data = data
	self:refreshUI()
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
		local child_transform = UIUtil.findTrans(transform,"child_transform")
		local attr_name_text = UIUtil.setText(child_transform, cp, "attr_name_text")
		-- 四舍五入保留小数点后一位
		local attr_value = cell_data[2] or 0
		attr_value = math.floor(attr_value * 10 + 0.5)/10
		local attr_value_text = nil
		if GameUtil:attrTransition(cell_data[1]) == true then
			attr_value_text = UIUtil.setText(child_transform, GameUtil:formatNum(attr_value).."%", "attr_value_text")
		else
			attr_value_text = UIUtil.setText(child_transform, GameUtil:formatNum(attr_value), "attr_value_text")
		end

		local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
		UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
		UIUtil.setObjectVisible(child_transform, false, "attr_add_value_text")
		UIUtil.setObjectVisible(transform, (k+1)%2 ~= 0, "bg_img")
	end
end

--[[	
	词缀属性列表
]]
function M:updateAffixLoopScroll(attrs)
	local data = {}
	for i, v in pairs(attrs) do
		table.insert(data, {i, v})
	end
	UIUtil.destroyAllChild(self.affix_attrs_node.transform)
	for k,cell_data in ipairs(data) do
		local cell_object = GameUtil:instanceObject(self.m_attr_node, self.affix_attrs_node.transform)
		cell_object:SetActive(true)
		local cp = GameUtil:getAttrsName(cell_data[1])
		local transform = cell_object.transform
		local attr_name_text = UIUtil.setText(transform, cp, "child_transform/attr_name_text")
		-- 四舍五入保留小数点后一位
		local attr_value = cell_data[2] or 0
		if  GameUtil:canPerAttrTransition(cell_data[1]) == true then
			attr_value = attr_value*100
		end
		attr_value = math.floor(attr_value * 10 + 0.5)/10
		local attr_value_text = nil
		if GameUtil:attrTransition(cell_data[1]) == true then
			attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value).."%", "child_transform/attr_value_text")
		else
			attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value), "child_transform/attr_value_text")
		end
		local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
		UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
		UIUtil.setObjectVisible(transform, false, "attr_add_value_text")
	end
end



--词缀属性
function M:getPolishedAttrs(equip_data, equip_cfg)
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	local affix_attrs = {} --洗练属性
	local affix_ts = nil --专属属性
	if equip_data and equip_data.affix then
		for k,v in pairs(equip_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg == nil then
				break
			end
			if affix_cfg.unique == 1 then
				affix_ts = {data = v, cfg = affix_cfg} 
			else
				local parm = {}
				parm.data = v
				parm.index = tonumber(k)
				if equip_cfg.quality == 8 then
					parm.cfg = affix_cfg.effect[1].random_value[0]
				elseif 	equip_cfg.quality >= 9 and equip_cfg.quality <= 11 then
					parm.cfg = affix_cfg.effect[1].random_value[equip_cfg.quality]
				else
					parm.cfg = affix_cfg.effect[1].random_value[0]	
				end
				table.insert(affix_attrs, parm)
			end
		end
	end
	return affix_attrs,affix_ts
end




function M:destroy()
	M.super.destroy(self)
end

return M