local M = class("ShiguangHerosControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "use_btn" then
        self:updateMsg("maze_revive_all", nil, "MazeStage")
    elseif msg == "refresh_ui" then
        self.m_maze_data = data.data
        self.m_view:refreshUI()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
