--药王角色的专属装备

--普通攻击时会治疗最虚弱的友军，使其恢复自己攻击力60%的生命值
--治疗量提升至90%的攻击力

--新：药王造成和受到的所有治疗效果提升20%

local YaoWang36_Trait1 = require("Battle.Ply.Trait.YaoWang36_Trait1")


---@class YaoWang36_Trait2 : YaoWang36_Trait1 @
---@field super YaoWang36_Trait1 @YaoWang36_Trait1
local M = class("YaoWang36_Trait2", YaoWang36_Trait1)



function M:init()
    M.super.init(self) 
    self.hpRecover = self:getValue(1) 
    self.cureRate = self:getValue(2) 
end
 

return M