
--威仪之戒 战斗中附近没有敌方单位时，增加7%攻击力

local Artifact6_0 = require("Battle.Artifact.Artifact6_0")


---@class Artifact6_2 : Artifact6_0 @
---@field super Artifact6_0 @Artifact6_0
local M = class("Artifact6_2", Artifact6_0)


function M:init(player,data)
    M.super.init(self, player, data)
    self.atk =  self:getValue(2)
    self.time = 0
end


return M