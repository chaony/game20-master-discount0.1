--角色的专属装备
--鬼谷 
--若鬼谷击杀了施加有诛邪印机的敌人，会为全体队友回复相当于鬼谷生命值300%攻击力的血量
--攻击具有诛邪印机的敌人时鬼谷造成的伤害提升20%


local W_GuiG_Trait0 = require("Battle.Ply.Trait.W_GuiG_Trait0")

---@class W_GuiG_Trait1 : W_GuiG_Trait0 @
---@field super W_GuiG_Trait0 @W_GuiG_Trait0
local M = class("W_GuiG_Trait1", W_GuiG_Trait0)


M.atk_vale = 0
function M:init()
    M.super.init(self)
    self.atk_vale = self:getValue(2)
     

end
--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim)

    if victim ~= nil  then
        local guigu_skill3 = victim.bufMgr:findBufByTag("guigu_skill3")
        if table.nums(guigu_skill3) > 0 then
            self.player.data.atk:addToMulListTemp(self.atk_vale)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M