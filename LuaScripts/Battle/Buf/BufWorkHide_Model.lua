--隐身（从场上消失）
---@class BufWorkHide : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkHide", BufWork_Model)

function M:initFinish()
    SceneManager.curScene.plyMgr:addHide(self.playerBuf.player)
    self.playerBuf.player.data:addInvincible(0)
end

function M:stop()
    M.super.stop(self)
    self.playerBuf.player.data:removeInvincible(0)
    SceneManager.curScene.plyMgr:removeHide(self.playerBuf.player)
    local player = SceneManager:getCurSceneModel().plyMgr:getPlayers(-self.playerBuf.player:get_camp())
    for i=player.Count,1,-1 do
        local player = player:get(i-1)
        player:removeKillerList()
    end
end

return M