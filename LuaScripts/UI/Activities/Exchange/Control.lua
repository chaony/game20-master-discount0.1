local M = class("ExchangePopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "change" then

    end
end

function M:changeNet(data)
    
end

return M;
