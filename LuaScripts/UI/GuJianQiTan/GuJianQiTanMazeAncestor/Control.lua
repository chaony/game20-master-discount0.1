local M = class("GuJianQiTanMazeAncestorControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:closeView()
    elseif msg == "ok_btn" then
        -- if self.m_model.m_cell_data.status == 0 then
        --     self:updateMsg("maze_goto", {data = self.m_model.m_cell_data}, "MazeStage")
        -- else
        --    self:updateMsg("goto_battle", {data = self.m_model.m_cell_data}, "MazeStage")
        -- end

        local cell_data = self.m_model.m_cell_data;
        local moveFinish = {
            callback = function()
                static_rootControl:updateMsg("goto_battle", {data = cell_data}, "GuJianQiTan.GuJianQiTanMaze")
            end
        }
        if self.m_model.m_callBack ~= nil then
            self.m_model.m_callBack( moveFinish )
        end
        self:closeView()
    end
end


return M
