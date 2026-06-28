--五毒角色的专属装备

--当场上的敌人数量为1/2/1时，大招的伤害会提升24%/12%/6%

--新：必杀技的伤害提升20%
local WuDu13_Trait0 = require("Battle.Ply.Trait.WuDu13_Trait0")


---@class WuDu13_Trait1 : WuDu13_Trait0 @
---@field super WuDu13_Trait0 @WuDu13_Trait0
local M = class("WuDu13_Trait1", WuDu13_Trait0)

function M:init()
    M.super.init(self)
    -- self.dmg1 = self:getValue(1) 
    -- self.dmg2 = self:getValue(2) 
    -- self.dmg3 = self:getValue(3) 
    self.dmg = self:getValue(1) 
end

-- function M:init()
--     M.super.init(self)
--     self.dmg1 = self:getValue(1) 
--     self.dmg2 = self:getValue(2) 
--     self.dmg3 = self:getValue(3)
-- end


return M