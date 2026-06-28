local M = class("HeroLvUpProPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "cancle_btn" then
        self:closeView()
    elseif msg == "ok_btn" then  
        if self.m_model.m_callback then
            self.m_model.m_callback()
        end
        self:closeView()
    end
    
end

return M;
