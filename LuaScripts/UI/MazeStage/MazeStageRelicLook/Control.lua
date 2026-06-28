local M = class("MazeStageRelicLookControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
