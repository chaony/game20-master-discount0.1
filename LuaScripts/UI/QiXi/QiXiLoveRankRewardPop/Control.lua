---@class DeliciousFeastRankRewardPopControl: OOControlBase
local M = class("QiXiLoveRankRewardPopPopControl",LikeOO.OOControlBase)

function M:onEnter()

end


function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 2 then
        self.m_model:setSelectIndex(msg)
        self.m_view:switchTabView()
    end
end

return M
