local M = class("CommonPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call(self.m_view:getText())
		end
		self:closeView()
	elseif msg == "cancle_btn" then
	    self:closeView()
    end
end

return M;
