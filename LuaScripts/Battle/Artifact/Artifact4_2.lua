
--圣灵披风 战斗中的生命回复效果加15%

local Artifact4_0 = require("Battle.Artifact.Artifact4_0")

---@class Artifact4_2 : Artifact4_0 @
---@field super Artifact4_0 @Artifact4_0
local M = class("Artifact4_2", Artifact4_0)


function M:init(player,data)
    M.super.init(self, player, data)
    self.sethp = self:getValue(1)
end


return M