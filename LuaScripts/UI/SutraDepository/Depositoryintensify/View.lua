local M = class("DepositoryintensifyView",LikeOO.OOPopBase)

M.m_uiName = "SutraDepository/MysticDepositoryintensify"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("ok_btn_text", "mystic_str_0042")
	self.m_gray_image = self:findImage("gray_image")
	self:setObjectVisible("UI_Myastic_ShuXing", false)
	self:setObjectVisible("UI_Myastic_ShuXing2", false)
	self:refreshUI()	
end

function M:refreshUI()
	local mystic_icon = self:findGameObject("MysicType_item")
	local value_text = self:findText("value_text")
	local title_valuetext = self:findText("title_valuetext")
	
	self.type_exp = nil
	self.consume = 0
	local cur_money = 0 --配置找当前心得
	local max_money = 0 --配置找最多需要心得
	if self.m_model.mystic_type == 1 then --外功
		self:setTextByLanKey("common_title_text", "mystic_str_0034")
		UIUtil.setImg(mystic_icon.transform, "a_cjg_icon_gonfahuang", "mystic_ui", "bg_img")
		UIUtil.setImg(mystic_icon.transform, "a_cjg_icon_xiaorenhuang", "mystic_ui", "img")
		self:setImg("a_lhg_waigong", "mystic_ui", "type_icon")
		self:setTextByLanKey("text", "mystic_str_0038")
		self.type_exp = "power_exp"
		self.consume  = 1
		self:setTextByLanKey("title_text", "mystic_str_0024")
		self:setText("title_valuetext", self.m_model.mystic_lv)
		-- self:setText("value_text",(cur_debris-1)* 100 .."%"..">>"..(max_debris -1) *100 .. "%")
		-- self:setText("value_text",(cur_debris-1)* 100 .."%"..">>"..(max_debris -1) *100 .. "%")
	elseif self.m_model.mystic_type == 2 then --身法身法
		self:setTextByLanKey("common_title_text", "mystic_str_0036")
		UIUtil.setImg(mystic_icon.transform, "a_cjg_icon_gonfalan", "mystic_ui", "bg_img")
		UIUtil.setImg(mystic_icon.transform, "a_cjg_icon_xiaorenlan", "mystic_ui", "img")
		self:setImg("a_lhg_shengfa", "mystic_ui", "type_icon")
		self:setTextByLanKey("text", "mystic_str_0040")
		self.type_exp = "speed_exp"
		self.consume  = 2
		self:setTextByLanKey("title_text", "mystic_str_0025")
		self:setText("title_valuetext", self.m_model.mystic_lv)
		-- self:setText("value_text", cur_debris..""..">>"..max_debris)
	elseif self.m_model.mystic_type == 3 then --内功
		self:setTextByLanKey("common_title_text", "mystic_str_0035")
		UIUtil.setImg(mystic_icon.transform, "a_cjg_icon_gonfahong", "mystic_ui", "bg_img")
		UIUtil.setImg(mystic_icon.transform, "a_cjg_icon_xiaorenhong", "mystic_ui", "img")
		self:setImg("a_lhg_neigong", "mystic_ui", "type_icon")
		self:setTextByLanKey("text", "mystic_str_0039")
		self.type_exp = "force_exp"
		self.consume  = 3
		self:setTextByLanKey("title_text", "mystic_str_0026")
		self:setText("title_valuetext", self.m_model.mystic_lv)
		-- self:setText("value_text", cur_debris..""..">>"..max_debris)
	elseif self.m_model.mystic_type == 4 then --绝技
		self:setTextByLanKey("common_title_text", "mystic_str_0037")
		UIUtil.setImg(mystic_icon.transform, "a_cjg_icon_gonfalv", "mystic_ui", "bg_img")
		UIUtil.setImg(mystic_icon.transform, "a_cjg_icon_xiaorenlv", "mystic_ui", "img")
		self:setImg("a_lhg_jueji", "mystic_ui", "type_icon")
		self:setTextByLanKey("text", "mystic_str_0041")
		self.consume  = 4
		self:setTextByLanKey("title_text", "mystic_str_0027")
		self:setText("title_valuetext", self.m_model.mystic_lv)
		self.type_exp = "super_exp"
	end

	local ok_btn = self:findButton("ok_btn")
	local mystic_upgrade = ConfigManager:getCfgByName("mystic_upgrade")
	local cfg_data = mystic_upgrade[self.m_model.mystic_lv]
	local consume_data = cfg_data.consumes[self.consume ] or {}
	cur_money = UserDataManager.user_data:getUserStatusDataByKey(self.type_exp)
	max_money = consume_data[1] and consume_data[1][3] or 0
	if mystic_upgrade[self.m_model.mystic_lv +1 ] then
		self:setText("value_text", ((cfg_data.hp_coef-1) * 100).."%".."-"..((mystic_upgrade[self.m_model.mystic_lv +1 ].hp_coef - 1) * 100) .. "%")
		--value_text.color = GlobalConfig.COMMON_COLLOR.COMMON_13
		--title_valuetext.color = Color.New(245/255, 63/255, 24/255)
		local ok_btn_img = self:findImage("ok_btn")
		if max_money > cur_money then
			ok_btn_img.material = self.m_gray_image.material
			ok_btn.interactable = false
		else
			ok_btn_img.material = nil
			ok_btn.interactable = true
		end
	else
		self:setText("value_text", ((cfg_data.hp_coef-1) * 100).."%".."(MAX)")
		self:setObjectVisible("ok_btn", false)
	end
	self:setText("money_value_text",max_money .. "/" .. cur_money)
end

function M:createObj(name,parent)
	local obj = ResourceUtil:LoadUIGameObject(name,Vector3.zero,parent)
	return obj
end

function M:show_effect(data)
	local UI_Myastic_ShuXing = self:findGameObject("UI_Myastic_ShuXing")
	UI_Myastic_ShuXing:SetActive(false)
	local UI_Myastic_ShuXing2 = self:findGameObject("UI_Myastic_ShuXing2")
	UI_Myastic_ShuXing2:SetActive(true)
	local mystic_upgrade = ConfigManager:getCfgByName("mystic_upgrade")
	local cfg_data = mystic_upgrade[data.mystic_slots[tostring(self.m_model.mystic_type)].lv]
	self:lockTouch()
	self.m_control:setOnceTimer(0.2, function()
		if not IsNull(UI_Myastic_ShuXing) then
			UI_Myastic_ShuXing:SetActive(true)
		end
		self:setText("value_text", ((cfg_data.hp_coef-1) * 100).."%"..">>"..((mystic_upgrade[data.mystic_slots[tostring(self.m_model.mystic_type)].lv +1 ].hp_coef - 1) * 100) .. "%")
	end)
	self.m_control:setOnceTimer(0.5, function()
		self:unlockTouch()
		if not IsNull(UI_Myastic_ShuXing) then
			UI_Myastic_ShuXing:SetActive(false)
		end
		if not IsNull(UI_Myastic_ShuXing2) then
			UI_Myastic_ShuXing2:SetActive(false)
		end
	end)
	self:setText("title_valuetext",data.mystic_slots[tostring(self.m_model.mystic_type)].lv)
	local mystic_upgrade = ConfigManager:getCfgByName("mystic_upgrade")
	local cfg_data = mystic_upgrade[data.mystic_slots[tostring(self.m_model.mystic_type)].lv]
	local consume_data = cfg_data.consumes[self.consume ]
	local cur_money = UserDataManager.user_data:getUserStatusDataByKey(self.type_exp)
	local max_money = consume_data[1][3]
	self:setText("money_value_text", cur_money.."/"..max_money)
end

function M:destroy()
    M.super.destroy(self)
end

return M