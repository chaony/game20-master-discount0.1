local M = class("CommonExclusivePopControl",LikeOO.OOControlBase)

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
    elseif msg == "select_hero" then
        self:openView("HeroInfo", {oid = data, look_model = 3 })  
    end
end

return M;
