--角色的专属装备
--锦衣 战斗中锦衣会获得20%的攻击提升
--战斗中锦衣会获得25%的攻击提升

local W_JinY_Trait0 = require("Battle.Ply.Trait.W_JinY_Trait0")

---@class W_JinY_Trait1 : W_JinY_Trait0 @
---@field super W_JinY_Trait0 @W_JinY_Trait0
local M = class("W_JinY_Trait1", W_JinY_Trait0)

function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)
  
end

return M