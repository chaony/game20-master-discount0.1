--角色的专属装备
--嵩山 嵩山的普通攻击会为敌方附加“冻伤”状态，冻伤状态下敌人受到的生命恢复效果减少40%冻伤会持续5秒单不可叠加
---@class W_SongS_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_SongS_Trait0", PlayerTrait)

M.equip_hero_id = 0

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.equip_hero_id = self:getValue(1)

end

function M:spawn()
    self.player.skillImprove:addItem("equip_hero",self.equip_hero_id)
end





function M:destroy()
    M.super.destroy(self)
end

return M