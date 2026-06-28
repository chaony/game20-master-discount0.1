local M = class("EquipmentLevelUpView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "HeroInfo/EquipmentLevelUp"
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", lua_name = "UI.HeroInfo.EquipmentLevelUp.EqpLevelUpNode", text_name = "tog_1_text", text_key = "equip_str_016", red_point_img = "tog_1_red_point_img" }, -- 升阶
	{btn_key = "tog_2", lua_name = "UI.HeroInfo.EquipmentLevelUp.EqpRecoinNode", text_name = "tog_2_text", text_key = "new_str_0514", red_point_img = "tog_2_red_point_img" }, -- 重铸
	{btn_key = "tog_3", lua_name = "UI.HeroInfo.EquipmentLevelUp.EqpPolishedNode", text_name = "tog_3_text",  text_key = "equip_str_020", red_point_img = "tog_3_red_point_img" ,open_id = 212}, -- 洗练
	{btn_key = "tog_4", lua_name = "UI.HeroInfo.EquipmentLevelUp.EqpBreakNode", text_name = "tog_4_text",  text_key = "equip_str_015", red_point_img = "tog_4_red_point_img" }, -- 突破
	{btn_key = "tog_5", lua_name = "UI.HeroInfo.EquipmentLevelUp.EqpGodLevelUpNode", text_name = "tog_5_text",  text_key = "equip_str_016", red_point_img = "tog_5_red_point_img" }, -- 突破
}

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0387")
    self.m_toggle_btns = {}
    self.m_content_panel = self:findGameObject("content_panel")
    for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_name, Language:getTextByKey(v.text_key))
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end, nil, self.m_uiName)
		self:setObjectVisible(v.red_point_img, false)
		if v.open_id then
			local open_bl = BtnOpenUtil:isBtnOpen(v.open_id)
			self:setObjectVisible(v.btn_key, open_bl == true)
		end
	end

	if self.m_model.cur_eqpcfg.quality < 8 then
		self:setObjectVisible("tog_3", false)
		self:setObjectVisible("tog_4", false)
	end
	--检查是否开启神兵强化
	if self.m_model:checkOpenAffixLvUp() == true then
		self:setObjectVisible("tog_5", true)
		self:setObjectVisible("tog_1", false)
		self:switchTabNode(5)
	else
		self:switchTabNode(1)
		self:setObjectVisible("tog_5", false)
		self:setObjectVisible("tog_1", true)	
	end
end

function M:refreshUI()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshUI()
    end
end

function M:setTagStatus(index)
	for k,v in pairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn_key)
		if k == index then
			tog_btn.isOn = true
		end
	end
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:switchTabNode(index)
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
    for k, v in pairs(__TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.text_name)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE_FOCUS or GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE
	end
	local btn_tab = __TAB_BTN_NODE[index]
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
end

function M:setEqpCell()
    if self.m_cur_tab_node and self.m_model.m_open_tab_index ==1 then
		self.m_cur_tab_node:setEqpCell()
	end
end

function M:updateLvUpUI(last_lv, last_num)
    if self.m_cur_tab_node and self.m_model.m_open_tab_index ==1 then
        self.m_cur_tab_node:updateLoopScroll()
        self.m_cur_tab_node:setCurEqp()
        self.m_cur_tab_node:setEqpCell()
        self.m_cur_tab_node:creatFx()
        self.m_cur_tab_node:PlaySliderAnim(last_lv, last_num)
    end
end

function M:setCurEqp()
    if self.m_cur_tab_node and self.m_model.m_open_tab_index ==1 then
        self.m_cur_tab_node:setCurEqp()
    end
end

function M:destroy()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
    M.super.destroy(self)
end


return M