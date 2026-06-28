--- 风华
--- 治疗效果增加30%
--- 治疗效果增加50%
---@class TalismanFengHua : Talisman
---@field super Talisman
local M = class("TalismanFengHua", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.buffId = self:getParam(1); --治疗效果buff
end

--战斗开始
function M:spawnFinish()
    self.player.bufMgr:addBufById(self.buffId, self.player)
end

return M;