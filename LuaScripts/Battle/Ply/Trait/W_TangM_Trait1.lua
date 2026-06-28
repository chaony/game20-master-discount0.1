--角色的专属装备
--唐门 所有蛇毒的伤害提升15%
--所有蛇毒的伤害提升20%

local W_TangM_Trait0 = require("Battle.Ply.Trait.W_TangM_Trait0")


---@class W_TangM_Trait1 : W_TangM_Trait0 @
---@field super W_TangM_Trait0 @W_TangM_Trait0
local M = class("W_TangM_Trait1", W_TangM_Trait0)



function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)

   
end


return M