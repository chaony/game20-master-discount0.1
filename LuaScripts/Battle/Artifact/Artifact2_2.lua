
--神王之眼 暴击时获得20%的攻速加成
local Artifact2_0 = require("Battle.Artifact.Artifact2_0")

---@class Artifact2_2 : Artifact2_0 @
---@field super Artifact2_0 @Artifact2_0
local M = class("Artifact2_2", Artifact2_0)

function M:init(player,data)
    M.super.init(self, player, data)
    self.speed = self:getValue(1)
end


return M