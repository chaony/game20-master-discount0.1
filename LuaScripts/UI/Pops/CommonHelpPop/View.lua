local M = class("CommonHelpPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonHelpPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {"help_toggle","histroy_toggle"}
function M:onEnter()
	self:setText("common_title_text",Language:getTextByKey(self.m_control.m_model.m_title or "???"))
	self.m_help_toggle_text = self:setText("help_toggle_text",Language:getTextByKey("new_str_0137"))
	self.m_histroy_toggle_text = self:setText("histroy_toggle_text",Language:getTextByKey("new_str_0138"))
	
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v)
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data) 
			end 
		end, i, self.m_uiName)
	end
	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_history == nil then
		self:setObjectVisible("toggle_group", false)
		local text_scroll_node = self:findGameObject("text_scroll_node")
		local rt = UIUtil.findRectTransform(text_scroll_node)
		rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), 402);  
	end

	if self.m_control.m_model.m_tab_index == 1 then
		local str = string.gsub(Language:getTextByKey(self.m_control.m_model.m_content or "???"), "\\n", "\n")
		self:setText("des_text",str)
		 self.m_help_toggle_text.color = GlobalConfig.COMMON_COLLOR.COMMON_24
		 self.m_histroy_toggle_text.color = GlobalConfig.COMMON_COLLOR.COMMON_25
		-- UIUtil.setOutlineExEffectColor(self.m_help_toggle_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_5)
		-- UIUtil.setOutlineExEffectColor(self.m_histroy_toggle_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_3)
	else
		local str = string.gsub(Language:getTextByKey(self.m_control.m_model.m_content or "???"), "\\n", "\n")
		self:setText("des_text",str)
		 self.m_help_toggle_text.color = GlobalConfig.COMMON_COLLOR.COMMON_25
		 self.m_histroy_toggle_text.color = GlobalConfig.COMMON_COLLOR.COMMON_24
		-- UIUtil.setOutlineExEffectColor(self.m_help_toggle_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_3)
		-- UIUtil.setOutlineExEffectColor(self.m_histroy_toggle_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_5)
	end
end

return M