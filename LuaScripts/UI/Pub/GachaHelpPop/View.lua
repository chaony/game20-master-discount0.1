local M = class("GachaHelpPopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/GachaHelpPop"
M.m_size_type = 2

local des_tab = {"Pub_str_0009", "Pub_str_0010", "Pub_str_0011", "Pub_str_0011", "Pub_str_0011", "Pub_str_0011", }
function M:onEnter()
	self:setTextByLanKey("title_text", des_tab[self.m_model.m_pool_id])
	self:setTextByLanKey("name_lv_text", "Pub_str_0012")
	self:setTextByLanKey("name_lan_text", "Pub_str_0013")
	self:setTextByLanKey("name_zi_text", "Pub_str_0014")
	local gacha = ConfigManager:getCfgByName("gacha")[self.m_model.m_pool_id]
	self:setText("value_1_text", gacha.show_probability[1])
	self:setText("value_2_text", gacha.show_probability[2])
	self:setText("value_3_text", gacha.show_probability[3])
end

return M