-- 灵鹫释放寒冰气息，在场上降下一片冰锥，攻击全体敌人造成100%攻击力的伤害，且使敌人速度降低20%

---@class W_LingJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LingJ_skill3_2_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.exDamage = self:getParam(1)
end

--攻击者的攻击开始处理
function M:killerBeforeAttack( attackData, victim )
    if victim ~= nil then
        local skillConfig = attackData.skillConfig
        if skillConfig == self.skill then
            local buffs = victim.bufMgr:findBufByTag("dog_hit")
            if #buffs > 0 then
                attackData.damage = attackData.damage + GlobalTools:Mul(attackData.damage, self.exDamage)
            end
        end
    end
end

return M