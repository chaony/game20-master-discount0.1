
local W_BaG_Trait0 = require("Battle.Ply.Trait.W_BaG_Trait0")

--角色的专属装备
--伤害提升值30%
---@class W_BaG_Trait1 : W_BaG_Trait0 @
---@field super W_BaG_Trait0 @W_BaG_Trait0
local M = class("W_BaG_Trait1", W_BaG_Trait0)


function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)
end

return M