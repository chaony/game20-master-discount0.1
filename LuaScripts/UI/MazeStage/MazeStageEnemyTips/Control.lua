local M = class("MazeStageEnemyTipsControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:closeView()
    end
end

return M
