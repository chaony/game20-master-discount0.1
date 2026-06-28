local M = class("NineActiveMainControl",LikeOO.OOControlBase)

function M:onEnter()
 
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn" then    -- 返回
        self:updateMsg("refreshNineActiveRedPoint", nil, "Xian")
        self:closeView()
    end
end


return M
