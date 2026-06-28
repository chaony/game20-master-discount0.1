local M = class("CommonSuccessPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonSuccessPop"
M.m_size_type = 2

function M:onEnter()
	local combat_change_bg_img = self:findGameObject("combat_change_bg_img")
	self.m_combat_up_effect = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_003", combat_change_bg_img)
	self:setParticleRenderOrder(self.m_combat_up_effect)
	self.m_combat_up_effect:SetActive(false)
	self:refreshUI()
	if self.m_model.m_sound_name and self.m_model.m_sound_name ~= "" then
		audio:SendEvtUI(self.m_model.m_sound_name)
	else
		audio:SendEvtUI("Ui_LevelUp_Player")
	end
end

function M:refreshUI()
	if self.m_model.m_cur_combat > self.m_model.m_last_combat then
		self.m_combat_up_effect:SetActive(true)
		self:setObjectVisible("combat_change_bg_img", true)
		self:setText("old_combat_text", GameUtil:formatValueToString(self.m_model.m_last_combat))
		self:setText("new_combat_text", GameUtil:formatValueToString(self.m_model.m_cur_combat))
		local function callBack()
			self.m_combat_up_effect:SetActive(false)
		end
		self.m_control:setOnceTimer(3,callBack)
	end
end

return M