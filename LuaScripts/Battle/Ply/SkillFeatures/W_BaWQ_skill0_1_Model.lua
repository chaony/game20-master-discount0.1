-- 唐伯虎在头顶告诉旋转长枪2秒，对周围敌人造成共计200%攻击力的伤害，旋转期间唐伯虎免疫控制，且受到的伤害减少50%，
-- 释放时若自身存在“枪头”，则会消耗一根枪头，再施展出一记横扫，对身前大范围内的敌人造成250%攻击力的伤害，并使其眩晕2秒

---@class W_BaWQ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaWQ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    
    self.addBuff1 = self:getParam(1)    -- Buff[] 技能期间控制免疫buffid
end

function M:skillStart(data)
    local skill1 = self:getSkill1()
    if (skill1 and skill1.curResLv > 0) then    -- 有枪头，提升效果
        self.skill.extra_anim_name = "skill0"
    else
        self.skill.extra_anim_name = "skill0_1"
    end
    M.super.skillStart(self, data)
    self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)       -- 免疫控制
end

function M:skillEnd(data)
    self.player.bufMgr:removeBufById(self.addBuff1, true)   -- 移除免疫控制
    M.super.skillEnd(self, data)
end

---@return W_BaWQ_skill1_3_Model
function M:getSkill1()
    if not self.skill1 then
        self.skill1 = self:getSkillFeature("skill1")
    end
    return self.skill1
end

return M