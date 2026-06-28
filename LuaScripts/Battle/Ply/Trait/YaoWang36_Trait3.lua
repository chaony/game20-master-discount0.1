--药王角色的专属装备

--普通攻击时会治疗最虚弱的友军，使其恢复自己攻击力60%的生命值
--治疗量提升至120%的攻击力

local YaoWang36_Trait2 = require("Battle.Ply.Trait.YaoWang36_Trait2")

---@class YaoWang36_Trait3 : YaoWang36_Trait2 @
---@field super YaoWang36_Trait2 @YaoWang36_Trait2
local M = class("YaoWang36_Trait3", YaoWang36_Trait2)



function M:init()
    M.super.init(self)
    self.hp = self:getValue(1) 
     
end

return M