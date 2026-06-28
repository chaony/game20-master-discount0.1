
--希望号角 每秒获得14点能量
local Artifact3_0 = require("Battle.Artifact.Artifact3_0")

---@class Artifact3_2 : Artifact3_0 @
---@field super Artifact3_0 @Artifact3_0
local M = class("Artifact3_2", Artifact3_0)

function M:init(player,data)
    M.super.init(self, player, data)
    self.energy = self:getValue(1)
end

return M