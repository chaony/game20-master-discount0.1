--绝对闪避
---@class BufWorkDodge : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkDodge", BufWork_Model)

function M:initFinish()
    local rate = self.playerBuf:checkParam("dodgeRate", GlobalTools.base1)
    self.dodgeRate = GlobalTools:Mul(rate, GlobalTools.base100)
end

function M:checkDodge()
    if self.dodgeRate < GlobalTools.base100 then
        local r = WRandom:randomNum(0, 100)
        return r < self.dodgeRate
    end
    return true
end

return M