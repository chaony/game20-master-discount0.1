--分担buf施加者的伤害
---@class BufWorkHurtShareOther : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkHurtShareOther", BufWork_Model)

function M:initFinish()
    --分享的伤害
    self.shareValue = self.playerBuf:checkParam("hurtShare", 0)
    --剩余的伤害
    self.remainValue = self.playerBuf:checkParam("hurtRemain", 1 - self.shareValue)
end

function M:stop()
    M.super.stop(self)

end

return M