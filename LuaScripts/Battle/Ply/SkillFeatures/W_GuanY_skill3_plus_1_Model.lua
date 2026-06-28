--关羽在原地留下一个残影并暂时脱离战场，随后带领骑兵冲锋席卷战场，
--对命中的所有敌人造成200%攻击力的伤害和2秒震慑，震慑结束后，还会为敌人施加持续5秒的“xx”状态，使敌人造成的伤害减少30%，
--冲锋期间关羽处于无敌状态，冲锋结束后关羽会回到原地；
---@class W_GuanY_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanY_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.player.skill3ClearAnger = true
end

function M:destroy()
    M.super.destroy(self)
end

return M