--选择一名最虚弱的敌方角色，对其造成300%攻击力的伤害，该技能无视敌方免死效果
---@class W_WanH_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanH_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:spawn()
    M.super.spawn(self)
    local skill1Item = self.player.plySkill:getSkillByName("skill1")
    if skill1Item ~= nil then
        self.skill1 = skill1Item.cur_skill_config.feature
    end
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skillConfig = attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
        attackData.ignoreAvoidDeath = true
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M