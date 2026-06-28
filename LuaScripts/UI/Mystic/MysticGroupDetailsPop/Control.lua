local M = class("MysticGroupDetailsPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    end
end

return M;
