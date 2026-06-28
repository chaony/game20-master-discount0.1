local M = class("ArenaHigherSeasonRankControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "left_btn" then
        
    elseif msg == "right_btn" then
        
    end
end

return M
