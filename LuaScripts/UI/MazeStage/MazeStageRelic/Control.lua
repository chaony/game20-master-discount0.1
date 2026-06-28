local M = class("MazeStageRelicControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cell_click" then
        self:openView("MazeStage.MazeStageRelicLook", data)
    end
end

function M:destroy()
    M.super.destroy(self)
    
end


return M
