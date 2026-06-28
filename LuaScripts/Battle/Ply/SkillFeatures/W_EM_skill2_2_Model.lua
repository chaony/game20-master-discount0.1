---@class W_EM_skill2_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_EM_skill2_2_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.rate = self:getParam(1)
    self.dmg = self:getParam(2)
end

function M:killerBeforeAttack(attackData, killer)
    M.super.killerBeforeAttack(self, attackData, killer)
    local skill  = attackData.skillConfig
    if skill ~= nil and skill.anim_name == "skill2" then
        local rate = killer.data:get_AngerRate();
        local anger = GlobalTools:Div( rate,self.rate )
        local anger_damage = GlobalTools:Mul(anger, self.dmg);
        attackData.damageLast = GlobalTools:Mul(attackData.damageLast, (1 + anger_damage))
    end
end

return M