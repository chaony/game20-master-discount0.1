--无敌
---@class BufWorkInvincible : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkInvincible", BufWork_Model)

function M:initFinish()
    
    self.internal = tonumber(self.playerBuf:checkParam("internal", 0))
    if self.internal ~= nil then
        self.playerBuf.player.data:addInvincible(self.internal)
    end
end

function M:stop()
    M.super.work(self)
    self.playerBuf.player.data:removeInvincible(self.internal)
end

return M