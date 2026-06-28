local M = class("GamePanelPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_btn1_call then
			self.m_model.m_btn1_call()
		end
        self:closeView()
    elseif msg == "btn_1" then
		if self.m_model.m_btn1_call then
			self.m_model.m_btn1_call()
		end
	    self:closeView()
	elseif msg == "btn_2" then
		if self.m_model.m_btn2_call then
			self.m_model.m_btn2_call()
		end
		self:closeView()
	elseif msg == "btn_3" then
		if self.m_model.m_btn3_call then
			self.m_model.m_btn3_call()
		end
	    self:closeView()
    end
end

return M;
