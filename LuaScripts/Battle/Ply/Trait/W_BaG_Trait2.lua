
local W_BaG_Trait1 = require("Battle.Ply.Trait.W_BaG_Trait1")

--角色的专属装备
--符合条件造成的伤害提升40%
---@class W_BaG_Trait2 : W_BaG_Trait1 @
---@field super W_BaG_Trait1 @W_BaG_Trait1
local M = class("W_BaG_Trait2", W_BaG_Trait1)


function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)
end



return M