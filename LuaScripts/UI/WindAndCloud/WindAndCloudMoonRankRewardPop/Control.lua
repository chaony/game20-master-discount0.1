---@class DeliciousFeastRankRewardPopControl: OOControlBase
local M = class("WindAndCloudMoonRankRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()

end


function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    end
end

return M
