local M = class("QiMenDunJiaMapControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then    -- 返回
        self:closeView()
    end
end

return M