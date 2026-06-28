--SP万灵之威：对一名敌人造成伤害和眩晕， 在祈灵状态下，若造成伤害后，目标生命值低于20%，直接将其秒杀。
---@class W_JiuLSP_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuLSP_skill1_1_Model", SkillFeatures_Model)

M.improve = false

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.killerHp = self:getParam(1)
    self.killerBuff = self:getParam(2)
end

function M:skillStart(data)
    self.skill.extra_anim_name = "skill1_2"
end

function M:killerAfterAttack(data)
    if self.player:equal(data.killer) and (data.attackData and data.attackData.skillConfig == self.skill) then
        local victim = data.victim
        M.super.killerAfterAttack(data)
        local hpRate = victim.data:get_hpRateAfterLost(data.damage)
        if hpRate < self.killerHp and self.player.bufMgr:hasBufByTag("W_JiuLSP_skill3") then
            local attackData, want_data = BattleTool:getHitDirectAttackData(self.player, victim.data:get_curHp())
            attackData.ignoreGuard = false
            attackData.ignoreAvoidDeath = true
            victim:beHitDirect(self.player, attackData, want_data, false)
            victim.bufMgr:addBufById(self.killerBuff, self.player, self.skill)
        end
    end
end


return M