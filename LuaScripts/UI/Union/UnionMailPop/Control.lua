local M = class("UnionMailControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
	    self:closeView()
    elseif msg == "ok_btn" then
		self:requestSendMail()
    end
end

function M:requestSendMail()
	local function mailCallback(response)
        self:updateMsg("refreshNetData",nil,"Union.UnionMain")
        self:closeView()
    end
    local params = {}
    params.mail_title = self.m_view:getTitleText()
    params.content = self.m_view:getDesText()
    if self.m_model.m_target_uid ~= -1 then
        params.target_uid = self.m_model.m_target_uid
    end
    self.m_model:getNetData("guild_send_mail", params, mailCallback)
end

return M;
