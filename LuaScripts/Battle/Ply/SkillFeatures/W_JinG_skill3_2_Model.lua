--该技能还会额外附加50%乘以骰子点数的伤害值
local W_JinG_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_JinG_skill3_1_Model")
---@class W_JinG_skill3_2_Model : W_JinG_skill3_1_Model @
---@field super W_JinG_skill3_1_Model @W_JinG_skill3_1_Model
local M = class("W_JinG_skill3_2_Model", W_JinG_skill3_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.frontDamage = self:getParam(6) --骰子附加伤害比例
end

function M:spawn()
    local skill = self.player.plySkill:getSkillByName("skill1")
    if skill ~= nil then
        self.skill1 = skill.cur_skill_config
    end
end


function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skillConfig = attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
        local frontDamage = 0
        if self.skill1 ~= nil then
            frontDamage = GlobalTools:Mul( self.frontDamage, self.skill1.feature.selfPoint )
        end
        attackData.damageFront = attackData.damageFront + frontDamage
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M