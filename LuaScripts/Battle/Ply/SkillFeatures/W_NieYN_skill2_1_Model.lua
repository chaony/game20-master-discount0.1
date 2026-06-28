-- 聂隐娘奋力的向前挥舞鞭刃，对前方敌人造成200%的伤害，受到伤害的敌人在5秒内内力恢复速度降低25%，并根据当前内力判定，内力值越低受到的伤害越高，最高额外受到300%的伤害。
--内力恢复速度降低40%
--最高额外伤害提高至400%
--如果目标是术士类型敌人，则无论当前内力值，均按照最低内力值计算

---@class W_NieYN_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_NieYN_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.angerExtraHurt = self:getParam(1) --内力值越低受到的伤害越高
    self.roleType = self:getParam(2)--职业
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if attackData.skillConfig == self.skill then
        local extraHurt = GlobalTools:Mul(self.angerExtraHurt, GlobalTools:Mul(victim.data:get_AngerRate(),GlobalTools.base100))
        if victim.plyData.role_type == self.roleType then
            extraHurt = GlobalTools:Mul(self.angerExtraHurt, GlobalTools.base100)
        end
        attackData["damageFront"] = attackData["damageFront"] + extraHurt
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M