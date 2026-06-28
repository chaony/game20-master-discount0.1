-- 蜀山扇动翅膀，迅速对当前目标造成三次80%攻击力的伤害，
-- 且若目标生命值敌人低于50%，则此攻击为真实伤害【真实伤害无视防御和伤害减免和护盾】

---@class W_ShuS_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill3 W_ShuS_skill3_1_Model
local M = class("W_ShuS_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.realDamageHpRate = self:getParam(1)   -- Fix[0-200]  -- 做成真实伤害血量百分比判定
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self:isInAir() then
        self.player.aiEngine.skillConfig.extra_anim_name = "skill1_skill3"
    else
        self.player.aiEngine.skillConfig.extra_anim_name = "skill1"
    end
end

function M:isInAir()
    if not self.skill3 then
        local skill3 = self.player.plySkill:getSkillByName("skill3")
        if skill3 and skill3.cur_skill_config then
            self.skill3 = skill3.cur_skill_config.feature
        end
    end
    return self.skill3 and self.skill3:isInAir()
end

---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if attackData.skillConfig == self.skill then
        if victim.data:get_hpRate() < self.realDamageHpRate then
            
            local isCrit = attackData.isCrit or attackData.mustCrit
            
            ---@type Battle_AttackData
            local attackDataNew = table.shallow_copy(attackData)
            attackDataNew.ignoreGuard = true
            attackDataNew.isCrit = isCrit
            ---@type Battle_BeHitDirectData_WantData
            local wantData = {}
            wantData.damage = attackData.damage
            if attackDataNew.isCrit then
                attackDataNew.damage = victim.data:calCritDamage(attackData.player, attackData.damage)
            end
            wantData.suck_value = self.player.data:leechingCal(wantData.damage)
            wantData.hasInjureMove = false
            attackDataNew.wantData = wantData
            victim:beHitDirect(attackData.player, attackDataNew, wantData, attackDataNew.isCrit, false)
            
            attackData.noAttack = true -- 不造成伤害
        end
    end
end

return M