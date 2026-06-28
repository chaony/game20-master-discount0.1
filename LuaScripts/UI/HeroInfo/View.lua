local M = class("HeroInfoView",LikeOO.OOPopBase)

M.m_uiName = "HeroInfo/HeroInfo"
M.m_iphoneXAdapter = true
local __TAB_BTN_NODE = { 
	--    show_sidebar(是否显示侧边栏)
	{btn_key = "tog_1", lua_name = "UI.HeroInfo.HeroAttributeNode", text_name = "tog_1_text", text_key = "hero_ui_str_0002", red_point_img = "tog_1_red_point_img" }, -- 属性
	{btn_key = "tog_2", lua_name = "UI.HeroInfo.HeroMeridianNode", text_name = "tog_2_text", text_key = "hero_ui_str_0006", red_point_img = "tog_2_red_point_img" }, -- 经脉
	{btn_key = "tog_3", lua_name = "UI.HeroInfo.HeroInfoNode", text_name = "tog_3_text",  text_key = "hero_ui_str_0010", red_point_img = "tog_3_red_point_img" }, -- 逸闻
}

local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} --金币
local tab_yueli = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} --粉尘

function M:onEnter()
	self:setTextByLanKey("close_title_text","new_str_0391")
	audio:SendEvtUI("Ui_Wushen_Open")
	self.m_content_panel = self:findGameObject("content_panel")
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_name, v.text_key)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		
		self:setObjectVisible(v.red_point_img, false)
		if k ~= 1 and tog_btn then
			local bl = self.m_model:checkMeridian()
			tog_btn.gameObject:SetActive(bl)
		end
	end  
	self:refreshUI(false)
	self:setObjectVisible("tog_lock2", false)
	self:playEnterAnim()
	if self.m_bg_scale ~= 1 then
        local bg_node = self:findGameObject("bg_obj")
        UIUtil.setScale(bg_node.transform, self.m_bg_scale)
	end
	local canvas = self.m_rootView:GetComponent("Canvas")
	if not IsNull(canvas) then
		canvas.sortingOrder = self.m_sortOrder + 1
	end
end


function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:switchTabNode(index, first_enter)
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	local btn_tab = __TAB_BTN_NODE[index]
	for k,v in pairs(__TAB_BTN_NODE) do
		local tog_text = self:findText(v.text_name)
		if index == k then
			tog_text.color = Color( 255/255, 253/255, 247/255)
		else
			tog_text.color = Color( 156/255, 214/255, 218/255)
		end
	end
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
	local com_close = self:findGameObject("CommonCloseNode")
	self:setCanvas(com_close, self.m_cur_tab_node.m_sortOrder)
end

function M:refreshUI(data)
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI(data)
	end
	local data = __TAB_BTN_NODE[2]
	local tog_btn = self:findGameObject(data.btn_key)

	if self.m_model:checkInitEvo() == true and self.m_model:checkExclusive() == true then
		--有经脉 -已开启
		self:setObjectVisible("tog_2", true)
		self:setObjectVisible("tog_lock", false)
	elseif self.m_model:checkInitEvo() == true and  self.m_model:checkExclusive() == false then 
		self:setObjectVisible("tog_2", true)
		self:setObjectVisible("tog_lock", true)
	else
		self:setObjectVisible("tog_2", false)	
		self:setObjectVisible("tog_lock", false)
		--self:setObjectVisible("tog_lock2", true)
	end

	self:updateAttrMoney()
	self:refreshBiograply()

end

function M:updateAttrMoney()
	local item_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0})
	self:setImg(item_data.icon_name, item_data.atlas_name, "money_img_3")
	self:setImg(self.m_model.data_coin.icon_name, self.m_model.data_exp.atlas_name, "money_img_1")
	self:setImg(self.m_model.data_exp.icon_name, self.m_model.data_exp.atlas_name, "money_img_2")
	self:setTextByLanKey("count_num_1", GameUtil:formatValueToString(self.m_model.data_coin.user_num))
	self:setTextByLanKey("count_num_2", GameUtil:formatValueToString(self.m_model.data_exp.user_num))
	self:setTextByLanKey("count_num_3", GameUtil:formatValueToString(item_data.user_num))
end

function M:refreshRedPoint()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshRedPoint()
	end
end

function M:refreshBiograply()
	-- if self.m_model.herocfg.evo <= 3 then
	-- 	self:setObjectVisible("tog_3", false)
	-- else
	-- 	self:setObjectVisible("tog_3", true)
	-- 	--暂时关闭传奇界面
	-- 	--self:setObjectVisible("tog_lock2", self.m_model.herocfg.map_event_team == 0)
	-- 	self:setObjectVisible("tog_lock2", true)
	-- end
end

function M:playEnterAnim()
	if self.m_cur_tab_node then
		if self.m_model.m_sel_tab_index == 1 or self.m_model.m_sel_tab_index == 0 then
			self.m_cur_tab_node:playAnim()	
		end
	end
end

function M:setLock()
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:setLock()
	end
end

function M:stopLevelup()
	if self.m_cur_tab_node  and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:stopLevelup()
	end
end

function M:hideTalk( )
	if self.m_cur_tab_node  and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:hideTalk()
	end
end

function M:talk(data)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1  then
		self.m_cur_tab_node:talk(data)
	end
end

function M:changeTab(index)
	self.m_toggle_btns[index].isOn = true
end

function M:clickTips(str)
	local m_data = {top = true}
	if str == "money_img_1" then
		local cur_obj = self:findGameObject("money_img_1")
		m_data.click_transform = cur_obj.transform
		m_data.data = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0} 
		m_data.top = false
	elseif 	str == "money_img_2" then
		local cur_obj = self:findGameObject("money_img_2")
		m_data.click_transform = cur_obj.transform
		m_data.data = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} 
		m_data.top = false
	elseif str == "money_img_3" then
		local cur_obj = self:findGameObject("money_img_3")
		m_data.click_transform = cur_obj.transform
		m_data.data = {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0} 
		m_data.top = false
	else
		if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1  then
			self.m_cur_tab_node:clickTips(str)
			return
		end		
	end
	GameUtil:lookInfoTips(self.m_control, m_data)
end

function M:updateSkillRedPoint(index, bl)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1  then
		self.m_cur_tab_node:updateSkillRedPoint(index, bl)
	end
end

function M:setCanvas(obj, num)
	local m_canvas = obj:GetComponent("Canvas")
	m_canvas.sortingOrder = num + 1
end

function M:creatCurEffect(index, new_bl)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:creatCurEffect(index, new_bl)
	end
end

function M:creatJuQiEffect()
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 2 then
		self.m_cur_tab_node:creatCurEffect()
	end
end

return M