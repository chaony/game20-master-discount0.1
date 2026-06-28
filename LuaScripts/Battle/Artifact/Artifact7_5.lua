
--永恒圣杯 战斗开始后的30秒内，每秒回复生命上限的1%生命

local Artifact7_2 = require("Battle.Artifact.Artifact7_2")

---@class Artifact7_5 : Artifact7_2 @
---@field super Artifact7_2 @Artifact7_2
local M = class("Artifact7_5", Artifact7_2)


function M:init(player,data)
    M.super.init(self, player, data)
    self.hp = self:getValue(2)
end


return M