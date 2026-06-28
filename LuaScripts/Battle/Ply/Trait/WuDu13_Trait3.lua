--五毒角色的专属装备

--当场上的敌人数量为1/2/1时，大招的伤害会提升48%/24%/12%

local WuDu13_Trait2 = require("Battle.Ply.Trait.WuDu13_Trait2")

---@class WuDu13_Trait3 : WuDu13_Trait2 @
---@field super WuDu13_Trait2 @WuDu13_Trait2
local M = class("WuDu13_Trait3", WuDu13_Trait2)

function M:init()
    M.super.init(self)
    self.dmg1 = self:getValue(1) 
    self.dmg2 = self:getValue(2) 
    self.dmg3 = self:getValue(3)
end

 

return M