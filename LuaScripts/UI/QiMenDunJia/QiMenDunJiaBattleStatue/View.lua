local M = class("QiMenDunJiaBattleStatueView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaBattleStatue"
M.m_size_type = 2

function M:onEnter()
	local massif_cfg = self.m_model:getBattleInfo()
	self:setTextByLanKey("common_title_text", massif_cfg.massif_name or "qi_men_dun_jia_str_032")
	self.m_detail_text_str = self:findText("detail_content").text
	self.m_property_text_str = self:findText("property_text").text
	self.m_explore_add_text_str = self:findText("explore_add_text").text
	self:refreshUI()
end

function M:refreshUI()
	self:updateProperty()
	self:updateButtonText()
	self:updateButtonStatus()
end

function M:updateProperty()
	local detail_text = self:findText("detail_content")
	detail_text.text = string.format(self.m_detail_text_str, tostring(self.m_model:getBuffValue()))
	local property_text = self:findText("property_text")
	property_text.text = string.format(self.m_property_text_str, tostring(self.m_model:getAllBuffValue()))
	local explore_add_text = self:findText("explore_add_text")
	explore_add_text.text = string.format(self.m_explore_add_text_str, tostring(self.m_model:getExploreAddValue()))
end

function M:updateButtonText()
	--self:setTextByLanKey("max_damage_text", "qi_men_dun_jia_str_004", self.m_model:getMaxDamage())
	self:setTextByLanKey("action_left_text", "qi_men_dun_jia_str_005", self.m_model:getStrength())
end

function M:updateButtonStatus()
	local strength_cur = self.m_model:getStrength()
	if strength_cur <= 0 then
		local statue_battle_btn_img = self:findImage("statue_battle_btn")
		statue_battle_btn_img.material = self:findText("material_node").material
		local btn_buy = self:findButton("statue_battle_btn")
		btn_buy.enabled = false
	end
end

return M