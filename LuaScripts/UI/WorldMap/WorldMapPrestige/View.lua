local M = class("WorldMapPrestigeView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapPrestige"
M.m_size_type = 2


local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", lua_name = "UI.WorldMap.WorldMapPrestige.PrestigeNode", text_key = "tog_1_text", show_text = "威望" , red_point_img = "battle_red_point_img"}, -- 威望
	{btn_key = "tog_2", lua_name = "UI.WorldMap.WorldMapPrestige.RankNode", text_key = "tog_2_text", show_text = "排行" , red_point_img = "battle_red_point_img"}, -- 排行
}

function M:onEnter()
	self.m_toggle_btns = {}
	self.m_content_panel = self:findGameObject("content_panel")
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		self:setObjectVisible(v.red_point_img, false)
	end
end

function M:refreshUI()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI()
	end
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg("check_tag", update_key)
	end
end

function M:switchTabNode(index)
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	self:setTextByLanKey("common_title_text", __TAB_BTN_NODE[index].show_text)
	for k,v in pairs(__TAB_BTN_NODE) do
		if k == self.m_model.m_sel_tab_index then
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_1 )
		else
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_5)
		end
	end
	local btn_tab = __TAB_BTN_NODE[index]
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
end

function M:setTime(tim)
	if self.m_cur_tab_node and self.m_model.m_sel_tab_index == 1 then
		self.m_cur_tab_node:setTime(tim)
	end
end

function M:itemFlyAction()

end

function M:destroy()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    M.super.destroy(self)
end

return M
