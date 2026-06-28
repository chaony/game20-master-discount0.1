local M = class("MysticPopView",LikeOO.OOPopBase)

M.m_uiName = "Mystic/MysticPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
						{btn = "use_toggle", lua_name = "UI.Mystic.MysticUsePanel", red_point_img = "use_toggle_red_point_img", btn_text = "use_taggle_text"},
						{btn = "upgrade_toggle", lua_name = "UI.Mystic.MysticUpgradePanel", red_point_img = "upgrade_toggle_red_point_img", btn_text = "upgrade_taggle_text"},	
}

function M:onEnter()
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1})
	self:setTextByLanKey("close_title_text", "new_str_0420")
	self:setTextByLanKey("upgrade_taggle_text", "mystic_str_0002")
	self:setTextByLanKey("use_taggle_text", "mystic_str_0003")
	self.toggle_panel = self:findGameObject("toggle_panel")
	self.child_panel = self:findGameObject("child_panel")

	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		if i == self.m_model.m_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data) 
			end 
		end, i, self.m_uiName)
		self:setObjectVisible(v.red_point_img, false)
	end
	self:AddChildPanel()
	self:refreshRedPoint()
end

function M:setToggle()
	local tab = __TAB_BTN_NODE[self.m_model.m_tab_index]
	local tog_btn = self:findToggle(tab.btn)
	tog_btn.isOn = true 
end

function M:refreshUI()
	self.m_cur_tab_node:refreshUI()
	self:refreshRedPoint()
end

function M:AddChildPanel()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	--if self.m_model.m_tab_index == 1 then
	--	self:setTextByLanKey("close_title_text", "mystic_str_0003")
	--else
	--	self:setTextByLanKey("close_title_text", "mystic_str_0002")	
	--end
	for k,v in pairs(__TAB_BTN_NODE) do
		local tog_text = self:findText(v.btn_text)
		if self.m_model.m_tab_index == k then
			tog_text.color = Color( 255/255, 253/255, 247/255)
		else
			tog_text.color = Color( 156/255, 214/255, 218/255)
		end
	end
	local btn_tab = __TAB_BTN_NODE[self.m_model.m_tab_index]
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.child_panel})
	end
end

function M:refreshRedPoint()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local flag = self.m_model:getRedPoint(i)
		local node = self:findGameObject(v.red_point_img)
		node:SetActive(flag)
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M