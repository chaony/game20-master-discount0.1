local M = class("OptionsHeadPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "tab_btn" then
    	self.m_model:setTab(data)
    	self.m_view:refreshUI()
    elseif msg == "ok_btn" then
    	if self.m_model.m_on_ok_call then
			self.m_model.m_on_ok_call()
		end
	    self:closeView()
	elseif msg == "cancel_btn" then
		self:closeView()
	elseif msg == "click_head" then
		self.m_model:setHeadSelect(data)
		self.m_view:refreshUI()
	elseif msg == "click_border" then
		self.m_model:setBorderSelect(data)
		self.m_view:refreshUI()
    end
end

return M;
