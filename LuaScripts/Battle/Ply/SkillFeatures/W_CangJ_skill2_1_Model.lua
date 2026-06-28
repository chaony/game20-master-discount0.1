-- 藏剑挥舞重剑，对前方范围内的敌人造成200%攻击力的伤害，并使命中的敌人眩晕2秒，该技能仅在“重剑决”姿态下可以释放，
---@class W_CangJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangJ_skill2_1_Model", SkillFeatures_Model)

function M:init(player, skill, className)
    M.super.init(self, player, skill, className)
end

function M:spawn()
    M.super.spawn(self)
    local skill3Item = self.player.plySkill:getSkillByName("skill3")
    if skill3Item ~= nil then
        self.skill3 = skill3Item.cur_skill_config.feature
    end
end

function M:canUse()
    return self.skill3.state == 1
end

function M:destroy()
    M.super.destroy(self)
end

return M