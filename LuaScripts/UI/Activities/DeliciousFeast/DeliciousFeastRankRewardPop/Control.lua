---@class DeliciousFeastRankRewardPopControl: OOControlBase
---@field m_model DeliciousFeastRankRewardPopModel
---@field m_view DeliciousFeastRankRewardPopView
local M = class("DeliciousFeastRankRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()

end


function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    end
end

return M
