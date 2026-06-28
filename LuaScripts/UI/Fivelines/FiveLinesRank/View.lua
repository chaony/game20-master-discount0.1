local M = class("FiveLinesRankView",LikeOO.OOPopBase)

M.m_uiName = "Fivelines/FiveLinesRank"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = { 
	--    show_sidebar(是否显示侧边栏)
	{btn_key = "tog_1", lua_name = "UI.Fivelines.FiveLinesRank.RankingNode", text_name = "tog_1_text", text_key = "排名"}, -- 排名
	{btn_key = "tog_2", lua_name = "UI.Fivelines.FiveLinesRank.DetailsNode", text_name = "tog_2_text", text_key = "详情" }, -- 详情
}

function M:onEnter()
    self.m_content_panel = self:findGameObject("content_panel")
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
	if index == 1 then
		self:setTextByLanKey("title_text", "排行榜")
	elseif index == 2 then	
		self:setTextByLanKey("title_text", "挑战记录")
	end
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
end

function M:destroy()
    M.super.destroy(self)
end

return M