local M = class("CommonItemTipsPopControl",LikeOO.OOControlBase)

function M:onEnter()
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(80)
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    end
end

function M:onDestroy()
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(120)
    end
end

return M;
