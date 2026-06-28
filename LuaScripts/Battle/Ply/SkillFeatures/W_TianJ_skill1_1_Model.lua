--天机消耗当前生命值的5%，重击前方敌人，对范围内的敌人造成200%攻击力的伤害，并附加自身10%最大生命值的伤害，被命中的敌人还会受到2秒的眩晕效果。
---@class W_TianJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianJ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --附加的攻击
    self.atkExtra = self:getParam(1)
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local skill = data.attackData.skillConfig
    if skill and skill.anim_name == "skill1" and data.attackData.injureType ~= "buff" then
        data.damage = data.damage + GlobalTools:Mul(self.player.data.hp:getValue(), self.atkExtra)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M