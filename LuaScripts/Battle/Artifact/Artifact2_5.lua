
--神王之眼 攻速提升之 25% 暴击伤害增加30%
local Artifact2_2 = require("Battle.Artifact.Artifact2_2")
---@class Artifact2_5 : Artifact2_2 @
---@field super Artifact2_2 @Artifact2_2
local M = class("Artifact2_5", Artifact2_2)

M.crit = nil

function M:init(player,data)
    M.super.init(self, player, data)
    self.speed = self:getValue(1)
    self.crit = self:getValue(3)
end

function M:gameStart()
    M.super.gameStart(self)
    self.player.data.crit:addToAddList(self.crit )  
end


return M