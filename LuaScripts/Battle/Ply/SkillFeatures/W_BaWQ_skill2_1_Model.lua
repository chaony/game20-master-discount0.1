-- 唐伯虎向前扔出长枪，长枪向前旋转并攻击路径上的所有敌人，长枪会在达到最远距离后返回，对敌人造成两段，每段160%攻击力的伤害，
-- 释放时若自身存在“枪头”，则会消耗一根枪头，使技能的伤害提升30%并提升攻击范围

---@class W_BaWQ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaWQ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.addBuff1 = self:getParam(1)   -- Buff[] 命中敌人获得护盾buff

    self.isSkillUpgrade = false -- 是否是消耗枪头提升过的技能
end

function M:skillStart(data)
    local skill1 = self:getSkill1()
    if (skill1 and skill1.curResLv > 0) then
        self.isSkillUpgrade = true
        self.skill.extra_anim_name = "skill2_1"
    else
        self.skill.extra_anim_name = "skill2"
    end
    M.super.skillStart(self, data)
end

---@return W_BaWQ_skill1_3_Model
function M:getSkill1()
    if not self.skill1 then
        self.skill1 = self:getSkillFeature("skill1")
    end
    return self.skill1
end

return M
