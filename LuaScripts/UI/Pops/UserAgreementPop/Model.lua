local M = class("UserAgreementPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_on_ok_call = self.m_params.on_ok_call
	self.m_on_cancel_call = self.m_params.on_cancel_call
	self.m_ok_text = self.m_params.ok_text or Language:getTextByKey("new_str_0624")
	self.m_cancel_text = self.m_params.cancel_text or Language:getTextByKey("new_str_0625")
	self.m_text = self.m_params.text or Language:getTextByKey("new_str_0626")
	self.m_title = self.m_params.title or Language:getTextByKey("new_str_0005")
	self.m_user_agreement_flag = UserDataManager.local_data:getLocalDataByKey("user_agreement_flag", 1)
end

function M:getUserAgreementFlag()
	return self.m_user_agreement_flag
end

function M:setUserAgreementFlag(value)
	self.m_user_agreement_flag = value or 1
end

return M
