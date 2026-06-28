--藏剑会瞬移至敌方生命值最低的敌人身后，并对其造成300%攻击力的伤害， 该技能仅在“轻剑决”姿态下可以释放，
---@class W_CangJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangJ_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:spawn()
    M.super.spawn(self)
    local skill3Item = self.player.plySkill:getSkillByName("skill3")
    if skill3Item ~= nil then
        self.skill3 = skill3Item.cur_skill_config.feature
    end
end

function M:canUse()
    return self.skill3.state == 2
end

function M:destroy()
    M.super.destroy(self)
end
return M