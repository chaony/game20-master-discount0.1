--- 怒潮
--- 初始增加内力50
--- 初始增加内力100
---@class TalismanNuChao : Talisman
---@field super Talisman
local M = class("TalismanNuChao", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.angerValue = self:getParam(1); --增加内力
end

--战斗开始
function M:spawnFinish()
    self.player.data:addAnger(self.angerValue, true)
end

return M;