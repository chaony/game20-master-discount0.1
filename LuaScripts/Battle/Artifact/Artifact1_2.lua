
--二级复苏之佑 护盾抵消的伤害量提升至170% 攻击力伤害
local Artifact1_0 = require("Battle.Artifact.Artifact1_0")
---@class Artifact1_2 : Artifact1_0 @
---@field super Artifact1_0 @Artifact1_0
local M = class("Artifact1_2", Artifact1_0)


function M:init(player,data)
    M.super.init(self, player, data)
    self.shileBuffid = self:getValue(1)
end
return M