local M = class("EquipmentPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "HeroInfo/EquipmentPop"
M.m_iphoneXAdapter = true
--
function M:onEnter()
	self.eqp_content = self:findGameObject("eqp_content")
	self.eqp_content_fitter = self.eqp_content:GetComponent("ContentImmediate")
	local sort_cont = self:findGameObject("sort_content")
	self:setTextByLanKey("intensify_text", "equip_str_035" )
	self:setTextByLanKey("zhanli_text", "new_str_0490" )
	self:setTextByLanKey("zhuangbei_text", "mystic_str_0007" )
	self:setTextByLanKey("shuxing_text", "equip_shuxing_text" )
	self:setTextByLanKey("cizhui_text", "equip_cizhui_text" )
	self:setTextByLanKey("buy_btn_text", "new_str_0037" )
	self:setTextByLanKey("cancle_text", "new_str_0885" )
	self:setTextByLanKey("ok_text", "equioment_pop_text" )
	if self.m_model:canRec() == true then
		self:setObjectVisible("recoin_btn", self.m_model:isRace())
		self:setObjectVisible("levelup_btn", false)--elf.m_model:canLevelUp())
	else
		self:setObjectVisible("rec_btn", false)
	end
	local equip_type_data = GlobalConfig.TYPE_EQUIP[tonumber(self.m_model.m_pos)]
	local pos_name = Language:getTextByKey(equip_type_data)
	self:setTextByLanKey("common_title_text",  pos_name)
	local data, cfg = self.m_model:getEquipData()
	self.m_icon_node = self:findGameObject("icon_node")
	if cfg then
		if data then
			local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race, data.oid}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
			GameUtil:updateItemEquipInfo(go, data)
			local luaBehaviour = UIUtil.findLuaBehaviour(go)
		else
			local race = self.m_model.m_race or 0
			if self.m_model.m_look_model == 3 and self.m_model.m_params.affix == true then
				race = self.m_model.m_equip_data.race or 0
			--elseif self.m_model.m_look_model == 3 and self.m_model.m_race then	
			--	race = self.m_model.m_race 
			end
			local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, race,self.m_model.m_eqp_id}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
		end
	end
	self:setTextByLanKey("jiacheng_text", "new_str_0472")
	self:setTextByLanKey("eqp_des_title_text", "new_str_0696")
	self:setTextByLanKey("smelt_btn_text", "new_str_1017")
	local open_flag, tips_str = BtnOpenUtil:isBtnOpen(211)
	self:setObjectVisible("smelt_btn", self.m_model.m_is_show_smelt_btn and open_flag)
	self:setObjectVisible("race_frame", false)
	self:setObjectVisible("race_img", false)
	self:setObjectVisible("jiacheng_type_text", false)
	self:setObjectVisible("race_obj", false)
	self.m_intensify_red_point_img = self:setObjectVisible("intensify_red_point_img", false)
	self.recoin_red_point_img = self:setObjectVisible("recoin_red_point_img", false)
	self.levelup_red_point_img = self:setObjectVisible("levelup_red_point_img", false)
    if cfg ~= nil then 
		self:setTextByLanKey("eqp_name_text", cfg.name)
		local color = GlobalConfig.QUALITY_COMMON_SETTING[cfg.quality]
		if cfg.quality >= 12 or cfg.lv_limit>0 then
			self:setObjectVisible("intensify_btn", true)
		else
			self:setObjectVisible("intensify_btn", false)
		end
		self:setTextByLanKey("pinzhi_text", cfg.quality_name)
		--self:setTextColor("eqp_name_text",color.RGBA)
		local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
		self:setImg(quality_item.icon, "common_ui", "quality_img") --品质图标
		local type_icon = GlobalConfig.TYPE_HERO_PROPERTY[cfg.type].pro_icon
		--self:setImg(type_icon,"hero_ui","type_img") --装备属性类型图标
		local type_name = GlobalConfig.TYPE_HERO_PROPERTY[cfg.type].name
		self:setTextByLanKey("zhuangbei_type_text", type_name)--装备属性类型名称
		self:setTextByLanKey("type_text", type_name)--装备属性类型名称
		self:setTextByLanKey("eqp_type_text", type_name)--装备属性类型名称
		self:setTextByLanKey("eqp_count_text", cfg.des)
		self:findGameObject("eqp_count_text"):GetComponent('ContentSizeFitter'):SetLayoutVertical();
		local attr = cfg.attr or {}
		local show_attrs = {}
		local attr_text = ""
		for k,v in pairs(attr) do
			if #v > 1 then
				local key = GameUtil:getAttrsKey(v[1])
				local atr_data = GameUtil:getAttrCfg(v[1])
				if atr_data.is_percent and  atr_data.is_percent == 1 then
					show_attrs[key] = v[2] * 100
				else
					show_attrs[key] = v[2] 
				end
			end
		end
		self:updateLoopScroll(show_attrs)
		local attrs = UserDataManager:appendAttrs(attr)	
		local combat = UserDataManager:computeEquipCombat(attrs)
		self:setTextByLanKey("combat_text",  GameUtil:formatValueToString(combat))
    end
	self:setTextByLanKey("race_add_value_text", "")
    if data ~= nil then
		if data.race ~= 0 then
			local race_item = GlobalConfig.TYPE_HERO_RACE[data.race]
			if race_item then
				local race_icon = race_item.race_icon
				self:setImg(race_icon,ResourceUtil:getLanAtlas(),"race_img") --装备种族类型图标
				local race_name = race_item.name
				-- self:setTextByLanKey("jiacheng_type_text", race_name)--装备种族类型名称
				self:setObjectVisible("race_img",true)
				self:setObjectVisible("race_frame", true)
				-- self:setObjectVisible("jiacheng_type_text",false)
				self:setObjectVisible("race_obj",true)
				local race_add_str = ""
				local race = data.race or 0
				local race_value = ConfigManager:getCommonValueById(45, 0)
				if race > 0 then
					local race_item = GlobalConfig.TYPE_HERO_RACE[race]
					local race_type = "【"..Language:getTextByKey(race_item.name)..Language:getTextByKey("new_str_0434").."】"
					if race_item then
						race_add_str = Language:getTextByKey("new_str_0644", race_type, race_value)
					end
				end
				self:setTextByLanKey("race_add_value_text", race_add_str)
			end
		end
		local count = ""
		local index = 0
		local h_race = self.m_model.herocfg and self.m_model.herocfg.race or 0
		local attrs = UserDataManager:getEquipAttrsByData(data, cfg, h_race, true)
		local or_data = table.copy(data)
		or_data.lv = 0
		local orig_attrs = UserDataManager:appendAttrs(self.m_model:getEquipBaseAttrs(or_data, cfg, h_race)) --基础属性
		self:updateLoopScroll(orig_attrs)
		local data1 = {}
		for i,v in ipairs(attrs) do
			local key = GameUtil:getAttrsKey(v[1])
			data1[key] = v[2]
		end
		local combat = UserDataManager:computeEquipCombat(data1)
		self:setTextByLanKey("combat_text", GameUtil:formatValueToString(combat))
	end
	self:setObjectVisible("btns_node", self.m_model.m_heroid ~= nil)
	self:setObjectVisible("cost_node", self.m_model.m_look_model == 2 and self.m_model.m_show_buy_btn == true)
	if self.m_model.m_look_model == 2 then
		if self.m_model.m_cost then
			local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
			local cost_num = GameUtil:formatValueToString(data.data_num)
			local user_num = GameUtil:formatValueToString(data.user_num)
			local cost_num_text = self:setTextByLanKey("cost_num_text", cost_num)
			cost_num_text.color = GlobalConfig.COMMON_COLLOR.COMMON_10
			self:setImg(data.icon_name, "item_icon", "cost_icon")
		end
		local hero_ids = self.m_model.m_hero_ids or {}
		self:setObjectVisible("heros_look_btn", #hero_ids > 0)
	else
		self:setObjectVisible("heros_look_btn", false)
	end
	self:refreshRedPoint()
	self:polishAttr()
	if self.m_model.m_look_model ~= 1 and  self.m_model.m_look_model ~= 2 and self.m_model.m_look_model ~= 3 then
		self:setObjectVisible("btns_node",  self.m_model.m_hide_btns == true)
	end

	self.today = self.m_model.m_today_btn_value
	self:setTextByLanKey("today_text", self.m_model.m_today_text)
	self:setObjectVisible("today_btn", self.m_model.m_isToday)
	if self.m_model.m_isToday then
		self:todayIsActive()
	end
end

function M:polishAttr()
	local affix_attrs,affix_ts = self.m_model:getPolishedAttrs()
	if affix_attrs and next(affix_attrs) then
		self:setObjectVisible("polish_panel", true)
		self:setObjectVisible("cizhui_title", true)
	else
		self:setObjectVisible("polish_panel", false)
		self:setObjectVisible("cizhui_title", false)
	end
	local attr_str = ""
	for i = 1, #affix_attrs do
		local cur_data = affix_attrs[i]
		local affix_data = cur_data.data
        local affix_cfg = cur_data.cfg
        if affix_data then
            local attr = affix_data.value[1]
            if next(attr) ~= nil then
                local atk_key = GameUtil:getAttrsKey(attr[2])
				local atk_name = GameUtil:getAttrsName(atk_key, attr[2])
                local cur_attr = ""
				local atr_num = attr[3]
				if  GameUtil:canPerAttrTransition(atk_key) == true then
					atr_num = atr_num*100
				end
                if GameUtil:attrTransition(atk_key) == true then
                    cur_attr = atr_num.."%"
                else
                    cur_attr = atr_num
                end
				--装备弹窗显示词缀颜色
				local atr_quality = GameUtil:checkAttrsQuality(affix_data.id)
				atr_quality.r = atr_quality.r*255
				atr_quality.g = atr_quality.g*255
				atr_quality.b = atr_quality.b*255
				local str_color = ColorHexHelper.ToHex24(atr_quality)
				if #affix_attrs == i then
					attr_str = attr_str.."<color="..str_color..">"..atk_name.."："..cur_attr.."</color>"
				else
					attr_str = attr_str.."<color="..str_color..">"..atk_name.."："..cur_attr.."</color>\n"
				end
         	end
		end	 
	end
	self:setTextByLanKey("attr_count_text",attr_str)
	if affix_ts and affix_ts.cfg then
		self:setTextByLanKey("special_count_text",Language:getTextByKey(affix_ts.cfg.affix_des))
		self:setObjectVisible("special_count_text", true)
		local bl = self.m_model:activateUniqueHero()
		if bl == true then
			self:setTextColor("special_count_text", Color(175/255, 108/255, 64/255))
		else
			self:setTextColor("special_count_text", Color(125/255, 125/255, 125/255))	
		end
		self:setObjectVisible("polish_panel2", true)
	else
		self:setObjectVisible("special_count_text", false)
		self:setObjectVisible("polish_panel2", false)
	end
end


function M:refreshUI()
	self.m_model:updateCurEquip()
	local data, cfg = self.m_model:getEquipData()
	UIUtil.destroyAllChild(self.m_icon_node.transform)
	if cfg then
		if data then
			local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
			GameUtil:updateItemEquipInfo(go, data)
			local luaBehaviour = UIUtil.findLuaBehaviour(go)
			local race_item = GlobalConfig.TYPE_HERO_RACE[data.race]
			local race_icon = race_item.race_icon
			self:setImg(race_icon, ResourceUtil:getLanAtlas(),"race_img") --装备种族类型图标
			self:setObjectVisible("race_img",true)
		else
			local go = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, 0}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
		end
	end
end


function M:updataEquip()
	UIUtil.destroyAllChild(self.m_icon_node)
	local data, cfg = self.m_model:getEquipData()
	if cfg then
		if data then
			local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
			GameUtil:updateItemEquipInfo(go, data)
			local luaBehaviour = UIUtil.findLuaBehaviour(go)
		else
			local go = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, 0}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
		end
	end
end

--是否是偶数
function M:IsOuNumber(num)
    local num1,num2=math.modf(num/2)--返回整数和小数部分
    if(num2==0)then
        return true
    else
        return false
    end
end

--[[	
	属性列表
]]
function M:updateLoopScroll(attrs)
	local data = {}
	for i, v in pairs(attrs) do
		table.insert(data, {i, {cur_num = v}})
	end
    table.sort(data,function(data1,data2)
		local id = GameUtil:getAttrsId(data1[1])
		local id2 = GameUtil:getAttrsId(data2[1])
		return tonumber(id)<tonumber(id2);
	end)
	self:updateAttrs(data)
end

function M:updateAttrs(data)
	local attr_parent = self:findGameObject("attrs_parent")
	UIUtil.destroyAllChild(attr_parent.transform)
	for i = 1,#data do
		local cell_obj = self:creatObjCell()
		cell_obj.transform:SetParent(attr_parent.transform, false)
		self:updateAttrCell(cell_obj, data[i])
	end
end

function M:creatObjCell()
	local item = ResourceUtil:LoadUIGameObject("HeroInfo/EquipmentPop_Cell", Vector3.zero, nil)
	return item
end

function M:updateAttrCell(obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local at_name = GameUtil:getAttrsName(cell_data[1]).."："
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", at_name)
		-- 四舍五入保留小数点后一位
		local attr_value = cell_data[2].cur_num or 0
		local book_base_attr = self.m_model:equipBookAttrById(cell_data[1])
		attr_value = math.floor(attr_value * 10 + 0.5)/10
		if GameUtil:attrTransition(cell_data[1]) == true then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_value_text", GameUtil:formatValueToString(attr_value).."%")
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_value_text", GameUtil:formatValueToString(attr_value))	
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "attr_add_value_text", false)
		if self.m_model:activateRace() == true then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "attr_add_value_text", true)
			local add_value = self.m_model:getRaceNum(cell_data[2].cur_num, cell_data[1])
			local add_value_text = nil
			if GameUtil:attrTransition(cell_data[1]) == true then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_add_value_text", "+"..GameUtil:formatValueToString(add_value).."%")
			else
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_add_value_text", "+"..GameUtil:formatValueToString(add_value))
			end
		else
			if cell_data[2].cur_num then
				local add_value = self.m_model:getLvUpNum(cell_data[2].cur_num, cell_data[1])
				if add_value > 0 then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "attr_add_value_text", true)
					local add_value_text = nil
					if GameUtil:attrTransition(cell_data[1]) == true then
						LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_add_value_text", "+"..GameUtil:formatValueToString(add_value).."%")
					else
						LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_add_value_text", "+"..GameUtil:formatValueToString(add_value))
					end
				end
			end
		end
	end
end

function M:refreshRedPoint()
	local red_flag = self.m_model:getEquipLevelUpRedPoint()
	self.m_intensify_red_point_img:SetActive(red_flag == true)

	if self.m_model.m_heroid then
		local red_flag = RedPointUtil:checkRecoinById(self.m_model.m_heroid, self.m_model.m_pos)
		self.recoin_red_point_img:SetActive(red_flag == true)
	end
	if self.m_model.m_heroid then
		local red_flag = RedPointUtil:checkSublimingById(self.m_model.m_heroid, self.m_model.m_pos)
		self.levelup_red_point_img:SetActive(red_flag == true)
	end
end

function M:todayIsActive(...)
	if self.today then
		self:setObjectVisible("yes", true)
		self.today_callback = true
		self.cur_server_ts = UserDataManager:getServerTime()
	else
		self:setObjectVisible("yes", false)
		self.today_callback = false
		self.cur_server_ts = nil
	end
end

return M