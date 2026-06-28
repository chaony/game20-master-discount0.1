--锁定血量（血量不再变化，不免疫死亡,配合NoDeath）
---@class BufWorkLockBlood_Model : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkLockBlood_Model", BufWork_Model)

function M:initFinish()
    self.playerBuf.player.data:setHpLock(true) 
end

function M:stop()
    self.playerBuf.player.data:setHpLock(false)
    M.super.stop(self)
end

return M