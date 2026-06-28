local M = class("UserAgreementPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/UserAgreementPop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("cancle_text", self.m_model.m_cancel_text)
	self:setTextByLanKey("ok_text", self.m_model.m_ok_text)
	self:setTextByLanKey("common_title_text", self.m_model.m_title)
	self:setTextByLanKey("msg_text", self.m_model.m_text)
	self:setTextByLanKey("tips_text", 'new_str_0627')
	self.m_big_close_btn = self:findButton("big_close_btn")
	self.m_big_close_btn.enabled = false
	self:setObjectVisible("close_btn", false)
	self:refreshUI()
end

function M:refreshUI()
	local user_agreement_flag = self.m_model:getUserAgreementFlag()
	self:setObjectVisible("select_img", user_agreement_flag == 1)
end

return M