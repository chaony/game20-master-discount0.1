--角色的专属装备
--唐门 所有蛇毒的伤害提升15%

--所有蛇毒的伤害提升25%

local W_TangM_Trait1 = require("Battle.Ply.Trait.W_TangM_Trait1")


---@class W_TangM_Trait2 : W_TangM_Trait1 @
---@field super W_TangM_Trait1 @W_TangM_Trait1
local M = class("W_TangM_Trait2", W_TangM_Trait1)



function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)

    
end


return M