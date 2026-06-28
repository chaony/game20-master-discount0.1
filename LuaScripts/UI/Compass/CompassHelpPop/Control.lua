local M = class("CompassHelpPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "tab_obg_1" then
        self.m_view:switchTabNode(1)
    elseif msg == "tab_obg_2" then
        self.m_view:switchTabNode(2)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
