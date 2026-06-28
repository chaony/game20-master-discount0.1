local M = class("CommonFiveLineHelpPopControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "back_btn" then
    	self:closeView()
    elseif msg == "tab_btn" then
    	self.m_model:setTab(data)
    	self.m_view:refreshUI()
    end
end


function M:destroy()
    M.super.destroy(self)
    
end

return M;
