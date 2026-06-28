local M = class("CommonItemsPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
    	if self.m_model.m_on_ok_call then
			self.m_model.m_on_ok_call()
		end
	    self:closeView()
    end
end

return M;
