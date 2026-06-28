--貂蝉
--lv4该技能对血量百分比低于30%的友军造成的恢复效果会增加50%
---@class W_DiaoC_skill0_4_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiaoC_skill0_4_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hpRate = self:getParam(1) --
    self.addRate = self:getParam(2) --
end

-- 治疗效果翻倍
function M:killerDataChangeTemp(victim, sourceSkill)
    --if self.skill == sourceSkill then
    local hpRate = victim.data:get_hpRate();
    if hpRate < self.hpRate and sourceSkill and self.skill == sourceSkill then
        self.player.data.cureRate:addToMAAListTemp(self.addRate, "skill_extra")
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M