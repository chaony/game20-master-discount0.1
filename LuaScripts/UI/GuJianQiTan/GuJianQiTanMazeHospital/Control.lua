local M = class("GuJianQiTanMazeHospitalControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:closeView()
    elseif msg == "ok_btn" then
        local cell_data = self.m_model.m_cell_data;
        local moveFinish = {
            callback = function()
                if cell_data.status == 0 then
                    --self:updateMsg("maze_goto", {data = self.m_model.m_cell_data}, "MazeStage")
                    -- else
                    if cell_data.type == 5 then --5.医馆
                        self:updateMsg("maze_add_blood", {data = cell_data}, "GuJianQiTan.GuJianQiTanMaze")
                    elseif cell_data.type == 6 then -- 6.药王庙
                        self:updateMsg("maze_revive_one", {data = cell_data}, "GuJianQiTan.GuJianQiTanMaze")
                    end
                end
            end
        }
        if self.m_model.m_callBack ~= nil then
            self.m_model.m_callBack( moveFinish )
        end
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
