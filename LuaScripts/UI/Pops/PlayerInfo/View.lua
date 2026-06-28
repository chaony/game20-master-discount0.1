---@class PlayerInfoView:OOPopBase
local M = class("PlayerInfoView",LikeOO.OOPopBase)

M.m_uiName = "Pops/PlayerInfo/PlayerInfo"
M.m_size_type = 2

function M:onEnter()
	self.m_toggle_btns = {}
	for k,v in pairs(self.m_model:getTabBtnNode()) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = k == self.m_model.m_open_tab_index and GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE_FOCUS or GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) 
			if is_on then
				self:updateMsg(k)
			end
		end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
	end
	self:setTextByLanKey("title_text", "options_str_0024")
	self.m_content_panel = self:findGameObject("content_panel")
	self:refreshUI()
end

function M:switchTabNode(index)
	for k,v in pairs(self.m_model:getTabBtnNode()) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE_FOCUS or GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE
		--local outline_width = index == k and 2 or 0
		--UIUtil.setOutlineExEffectColor(cur_tab_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_3, outline_width)
	end
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	local tab_btn_node = self.m_model:getTabBtnNode()
	local btn_tab = tab_btn_node[index]
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
		self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel, index = index})
		self:setTextByLanKey("common_title_text", "options_str_0013")

		-- self:setTextByLanKey("common_title_text", btn_tab.title_key)
	end
end

function M:refreshUI()

end

function M:destroy()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
    M.super.destroy(self)
end

return M