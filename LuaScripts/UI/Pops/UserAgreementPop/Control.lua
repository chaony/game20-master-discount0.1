local M = class("UserAgreementPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
    elseif msg == "ok_btn" then
		local user_agreement_flag = self.m_model:getUserAgreementFlag()
		if user_agreement_flag ~= 1 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0629"), delay_close = 2})
			return
		end
		UserDataManager.local_data:setLocalDataByKey("user_agreement_flag", 1)
		if self.m_model.m_on_ok_call then
			self.m_model.m_on_ok_call()
		end
	    self:closeView()
	elseif msg == "cancle_btn" then
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
	    self:closeView()
	elseif msg == "look_btn" then -- 查看用户协议
		-- 暂时只有小米有隐私协议提示
		SDKUtil:openUrl("https://privacy.mi.com/xiaomigame-sdk/zh_CN/")
	elseif msg == "agree_btn" then -- 同意或不同意
		local user_agreement_flag = self.m_model:getUserAgreementFlag()
		self.m_model:setUserAgreementFlag(user_agreement_flag == 0 and 1 or 0)
		self.m_view:refreshUI()
    end
end

return M;
