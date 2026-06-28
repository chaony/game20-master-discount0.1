--角色的专属装备
--鬼谷 
--若鬼谷击杀了施加有诛邪印机的敌人，会为全体队友回复相当于鬼谷生命值300%攻击力的血量
--还会为全体队友回复100点内力

local W_GuiG_Trait1 = require("Battle.Ply.Trait.W_GuiG_Trait1")

---@class W_GuiG_Trait2 : W_GuiG_Trait1 @
---@field super W_GuiG_Trait1 @W_GuiG_Trait1
local M = class("W_GuiG_Trait2", W_GuiG_Trait1)

M.anger = 0
function M:init()
    M.super.init(self)
    self.anger = self:getValue(3)
    

end



function M:restValue( enemy_player )
    enemy_player.angerData:addAnger(self.anger)
end

return M