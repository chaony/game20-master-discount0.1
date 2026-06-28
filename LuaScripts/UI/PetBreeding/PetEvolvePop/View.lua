---@class PetEvolvePopView: OOPopBase
---@field m_model PetEvolvePopModel
local M = class("PetEvolvePopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetEvolvePop"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", lua_name = "UI.PetBreeding.PetEvolvePop.PetEvolveNode", text_name = "tog_1_text", text_key ="进化",red_point_img="tog_1_red_point_img" }, -- 升阶
	{btn_key = "tog_2", lua_name = "UI.PetBreeding.PetEvolvePop.PetCompreheadNode", text_name = "tog_2_text", text_key ="领悟",red_point_img="tog_2_red_point_img"}, -- 领悟
}


function M:onEnter()
    self.m_content_panel = self:findGameObject("content_panel")
	self:setTextByLanKey("common_title_text", "pet_evo_lv_0005")
    -- for k,v in pairs(__TAB_BTN_NODE) do
	-- 	self:setTextByLanKey(v.text_name, Language:getTextByKey(v.text_key))
	-- 	local tog_btn = self:findToggle(v.btn_key)
	-- 	if k == self.m_model.m_open_tab_index then
	-- 		tog_btn.isOn = true
	-- 	end
	-- 	UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end, nil, self.m_uiName)
	-- 	self:setObjectVisible(v.red_point_img, false)
	-- 	if v.open_id then
	-- 		local open_bl = BtnOpenUtil:isBtnOpen(v.open_id)
	-- 		self:setObjectVisible(v.btn_key, open_bl == true)
	-- 	end
	-- end
    self:switchTabNode(self.m_model.m_type)
end

function M:refreshUI()
    if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI()
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
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_5
	end
	local btn_tab = __TAB_BTN_NODE[index]
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
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
