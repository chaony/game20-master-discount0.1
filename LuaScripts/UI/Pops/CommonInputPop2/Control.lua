local M = class("CommonPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
    elseif msg == "ok_btn" then
		if self.m_model.m_on_ok_call then
			local params = {}
			params.text = self.m_view:getText()
			self.m_model.m_on_ok_call(params)
		end
		self:closeView()
	elseif msg == "cancle_btn" then
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
	    self:closeView()
	elseif msg == "reset_input_text" then
		self.m_view:setInputText("")
    end
end

return M;
