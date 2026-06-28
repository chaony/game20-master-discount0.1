local M = class("ShiguangView",LikeOO.OOPopBase)

M.m_uiName = "ShiGuang/Shiguang"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("hero_btn_text", "new_str_0433")
	self:setTextByLanKey("event_list_btn_text", "new_str_0427")
	self:setTextByLanKey("reset_btn_text", "new_str_0432")
	self:setTextByLanKey("close_title_text", "rpg_scroll_1")
    self:refreshUI()
end

function M:refreshUI()
	local heirloom_num = self.m_model:getHeirloomNum()
	for k,v in pairs({7,5,3}) do
		local heirloom_num_item = heirloom_num[v] or {}
		self:setTextByLanKey("attr_add_text_" .. k, tostring(heirloom_num_item.num or 0))	
	end
	local add_value, heros_combat = self.m_model:getHeirloomCombatAddRatio()
	self:setText("combat_add_value_text", string.format("+%0.2f%%", add_value*100))
	self:setText("combat_num_text", tostring(heros_combat))
end

function M:destroy()
	
    M.super.destroy(self)
end

return M