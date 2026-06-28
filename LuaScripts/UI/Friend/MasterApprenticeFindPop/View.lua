local M = class("MasterApprenticeFindPopView",LikeOO.OOPopBase)

M.m_uiName = "Friend/MasterApprenticeFindPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {
	{btn = "tog_1", lua_name = "UI.Friend.MasterApprenticeFindPop.ApplyNode", text_name = "tog1_text", show_name = "master_apprentice_str_0023", red_point_img ="tog_1_red_point_img"},
	{btn = "tog_2", lua_name = "UI.Friend.MasterApprenticeFindPop.FindNode", text_name = "tog2_text", show_name = "", red_point_img ="tog_2_red_point_img"},
}

function M:onEnter()
	self:setTextByLanKey("common_title_text", "master_apprentice_str_0031")
	self.child_panel = self:findGameObject("child_panel")
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		if v.show_name == "" and self.m_model.m_status == 1 then
			self:setTextByLanKey(v.text_name, "master_apprentice_str_0021")
		elseif v.show_name == "" and self.m_model.m_status == 2 then 
			self:setTextByLanKey(v.text_name, "master_apprentice_str_0022")
		else		
			self:setTextByLanKey(v.text_name, v.show_name)
		end
	
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data) 
			end 
		end, i, self.m_uiName)
		self:setObjectVisible(v.red_point_img, false)
	end
	self:AddChildPanel()
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
	local btn_tab = __TAB_BTN_NODE[self.m_model.m_tab_index]
	local tog_btn = self:findToggle(btn_tab.btn)
	if tog_btn then
		tog_btn.isOn = true
	end
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.child_panel})
	end
end

function M:refreshRedPoint()
    for k, v in pairs(__TAB_BTN_NODE) do
        local red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
        self:setObjectVisible(v.red_point_img, red_flag == true)
    end
end

return M