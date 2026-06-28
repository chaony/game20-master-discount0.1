local M = class("QiXiShoppingRankControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    end
end

return M
