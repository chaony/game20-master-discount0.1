--五毒角色的专属装备

--当场上的敌人数量为1/2/1时，大招的伤害会提升36%/18%/9%

--新：必杀技提升30%
local WuDu13_Trait1 = require("Battle.Ply.Trait.WuDu13_Trait1")

---@class WuDu13_Trait2 : WuDu13_Trait1 @
---@field super WuDu13_Trait1 @WuDu13_Trait1
local M = class("WuDu13_Trait2", WuDu13_Trait1)

function M:init()
    M.super.init(self)
    -- self.dmg1 = self:getValue(1) 
    -- self.dmg2 = self:getValue(2) 
    -- self.dmg3 = self:getValue(3)
    
    self.dmg = self:getValue(1) 
end


return M