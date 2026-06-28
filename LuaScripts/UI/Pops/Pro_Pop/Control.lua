local M = class("Pro_PopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "cancle_btn" then
    	self:closeView()
    end
end

return M;
