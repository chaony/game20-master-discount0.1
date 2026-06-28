local M = class("FormationSetView",LikeOO.OOPopBase)

M.m_uiName = "Formation/FormationSet"
M.m_size_type = 1

local __TAB_BTN_NODE = { 
	--    show_sidebar(是否显示侧边栏)
	{btn_key = "tog_1", lua_name = "UI.Formation.FormationSet.HeroListNode", text_name = "tog_1_text", text_key = "new_str_0433"}, -- 武神
	{btn_key = "tog_2", lua_name = "UI.Formation.FormationSet.DeploymentNode", text_name = "tog_2_text", text_key = "new_str_0520" }, -- 阵容
}

function M:onEnter()
	self.m_content_panel = self:findGameObject("node_panel")
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_name, v.text_key)
		local tog_btn = self:findToggle(v.btn_key)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
	end  
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:refreshUI()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI()
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
	-- local com_close = self:findGameObject("CommonCloseNode")
	-- self:setCanvas(com_close, self.m_cur_tab_node.m_sortOrder)
end

--武神筛选类型
function M:switchHeroTypeBtn(index)
	if self.m_model.m_sel_tab_index == 1 and self.m_cur_tab_node then
		self.m_cur_tab_node:switchHeroTypeBtn(index)
	end
end

return M