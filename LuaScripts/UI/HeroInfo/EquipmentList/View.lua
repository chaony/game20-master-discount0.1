local M = class("EquipmentListView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "HeroInfo/EquipmentList"
M.m_iphoneXAdapter = true
function M:onEnter()
	self.m_center = self:findGameObject("center")
	self:setObjectVisible("nil_bg_img",false)
	self:setObjectVisible("have_bg_img",false)
	self:setObjectVisible("cur_equip",false)
	self:setObjectVisible("nil_eqp",false)
	if self.m_model.m_eqp_data then
		self:setCurEquip()
		self:setObjectVisible("cur_equip",true)
		self:setObjectVisible("have_bg_img",true)
	else
		self:setObjectVisible("nil_bg_img",false)
		self:setObjectVisible("nil_eqp",true)
	end
	self:setTextByLanKey("nil_eqp_text","new_str_0068")
	self:setTextByLanKey("nil_caneqp_text","new_str_0069")
	self:setTextByLanKey("cur_text","cur_equip_tex")
	self:setTextByLanKey("zhan_text",Language:getTextByKey("new_str_0490")..":" )
	self:updateLoopScroll()
	local equip_type_data = GlobalConfig.TYPE_EQUIP[self.m_model.m_pos]
	local pos_name = Language:getTextByKey(equip_type_data)
	self:setTextByLanKey("common_title_text",  pos_name)
	self:setTextByLanKey("common_no_have_text", "new_str_0695")
	
end

--当前部位穿戴中的装备
function M:setCurEquip()
	local data, cfg = self.m_model:getCurEquip()
	self:setObjectVisible("cur_equip",true)
	self.m_icon_node = self:findGameObject("equ_parent")
	if cfg then
		if data then
			local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
			GameUtil:updateItemEquipInfo(go, data)
			self:setTextByLanKey("cureqp_combat_text", self.m_model:getCurEqpCombat())
		else
			local go = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cfg.id, 0}, false, false)
			go.transform:SetParent(self.m_icon_node.transform, false)
		end
		self:setTextByLanKey("cureqp_text", cfg.name)
		local color = GlobalConfig.QUALITY_COMMON_SETTING[cfg.quality]
		self:setTextColor("cureqp_text", color.RGBA)
		if data and data.affix then
			local affix_combat = math.ceil(UserDataManager:getEquipAffixCombat(data))
			self:setTextByLanKey("cur_affix_text", "equip_str_027", affix_combat)
			self:setObjectVisible("cur_affix_text", true)
		else
			self:setObjectVisible("cur_affix_text", false)
		end
	end
end

--[[
	创建装备列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowEquipCount()
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
	local eqp_cfg = UserDataManager.equip_data:getEquipConfigByCid(eqp_data.id)
	if obj == nil or eqp_data ==nil or eqp_cfg == nil then 
		Logger.log("<color=red>Error setEqpInfo  Is Nil </color>")
		return 
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local m_icon_node = UIUtil.findTrans(obj.transform, "itemParent")
	UIUtil.destroyAllChild(m_icon_node)
	if eqp_cfg then
		if eqp_data then
			local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, eqp_data.id, eqp_data.race}, false, false)
			go.transform:SetParent(m_icon_node, false)
			GameUtil:updateItemEquipInfo(go, eqp_data)
		else
			local go = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, eqp_cfg.id, 0}, false, false)
			go.transform:SetParent(m_icon_node, false)
		end
	end
	
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "replace_btn_text", "new_str_0885") 
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "check_btn_text", "new_str_0042") 
	local color = GlobalConfig.QUALITY_COMMON_SETTING[eqp_cfg.quality]
	local frame = GlobalConfig.QUALITY_COMMON_SETTING[eqp_cfg.quality]
	if luaBehaviour then
		local name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name_text", eqp_cfg.name) --装备名字
		local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(eqp_data, eqp_cfg, self.m_model:checkHeroRace())) 
		local combat = UserDataManager:computeEquipCombat(attrs)  
		local combat_text = nil
		if eqp_data.affix then
			local affix_combat = math.ceil(UserDataManager:getEquipAffixCombat(eqp_data)) 
			-- combat = combat + affix_combat
			local show_str = Language:getTextByKey("new_str_0490")..":"..GameUtil:formatValueToString(combat).."<color=#509FEF> ["..affix_combat.."]</color>"
			combat_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", show_str) 
		else
			combat_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", Language:getTextByKey("new_str_0490")..":"..GameUtil:formatValueToString(combat)) 
		end
		LuaBehaviourUtil.setImg(luaBehaviour,"icon_img",eqp_cfg.icon,"equip_icon")--装备Icon
		LuaBehaviourUtil.setImg(luaBehaviour,"kuang_img", frame.frame_name, "equip_icon")--装备外框
		name_text.color = color.RGBA
		local owner = eqp_data.owner or {}
		if #owner > 0 then --是否是已被其他人装备的
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "replace_btn", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "owner_obj", true)
			local data = self.m_model:getImgById(owner)
			if data then
				local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, data.oid})
				LuaBehaviourUtil.setImg(luaBehaviour, "card_img", reward_data.icon_name, reward_data.atlas_name)
			end
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "replace_btn", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "owner_obj", false)
		end
		if eqp_cfg and eqp_cfg.pos == 1 and eqp_data and eqp_data.affix then
			local hero_id = self.m_model:checkAffixAttr(eqp_data)
			if hero_id and hero_id > 0 then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_affix_name", self.m_model:getHeroNameByCid(hero_id))
			end
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_affix_text", true)
			UIUtil.setLocalPosition(name_text.gameObject.transform, nil, 80)
			UIUtil.setLocalPosition(combat_text.gameObject.transform, nil, 50)
		else
			UIUtil.setLocalPosition(name_text.gameObject.transform, nil, 68)
			UIUtil.setLocalPosition(combat_text.gameObject.transform, nil, 33)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_affix_text", false)
		end
	end
end


return M