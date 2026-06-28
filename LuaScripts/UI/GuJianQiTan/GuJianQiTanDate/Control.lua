local M = class("GuJianQiTanDateControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    end
end

return M;
