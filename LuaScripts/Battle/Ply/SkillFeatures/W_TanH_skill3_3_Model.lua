--该技能现在同样能获得普攻的强化效果
local W_TanH_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_TanH_skill3_1_Model")
---@class W_TanH_skill3_3_Model : W_TanH_skill3_1_Model @
---@field super W_TanH_skill3_1_Model @W_TanH_skill3_1_Model
local M = class("W_TanH_skill3_3_Model", W_TanH_skill3_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    self.skill2 = self.player.plySkill:getSkillByName("skill2")
    self.skill1 = self.player.plySkill:getSkillByName("skill1")
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    
    if self.skill == attackData.skillConfig then
        -- 不会被闪避强化
        if self.skill1 ~= nil and self.skill1.cur_skill_config.feature ~= nil then
            attackData.mustHit = self.skill1.cur_skill_config.feature.mustHit or false
        end

        -- 必定暴击，无视护盾
        ---@type W_TanH_skill2_1_Model
        local skill2_feature = self.skill2 ~= nil and self.skill2.cur_skill_config.feature
        if skill2_feature and skill2_feature.isImprove == true then
            attackData.ignoreGuard = true
            if skill2_feature.armorBreak == true then
                attackData.armorBreak = true
            end
        end
    end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
    M.super.killerDataChangeTemp(self, victim, skill)
    if self.skill == skill then
        if self.skill1 ~= nil and self.skill1.cur_skill_config.feature ~= nil then
            self.player.data.crit:addToAddListTemp(self.skill1.cur_skill_config.feature.crit)
        end
        if self.skill2 ~= nil and self.skill2.cur_skill_config.feature.isImprove == true then
            self.player.data.critrate:addToAddListTemp(self.skill2.cur_skill_config.feature.critrate)
            self.player.data.physicaldamage:addToMulListTemp(self.skill2.cur_skill_config.feature.dmg)
            self.player.data.magicdamage:addToMulListTemp(self.skill2.cur_skill_config.feature.dmg)
        end
    end
end

return M