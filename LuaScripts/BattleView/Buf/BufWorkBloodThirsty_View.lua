--吸血增强下次攻击
---@class BufWorkBloodThirsty_View : BufWork_View @
---@field super BufWork_View @BufWork_View
local M = class("BufWorkBloodThirsty_View", BufWork_View)

function M:init( buf, model )
    M.super.init(self, buf, model)
    self:addEventListener_Local(Battle.EventType.MV_BufWorkBloodThirstyShowHitLable, {self, self.MV_BufWorkBloodThirstyShowHitLable})
end

function M:MV_BufWorkBloodThirstyShowHitLable(eventName, data)
    self.playerBuf.player:createHpNumberLabel("-", Mathf.Floor(data), 0)
end

return M