--林冲锁定一名敌方侠客，立即瞬移至其身后，并对其造成300%攻击力的伤害，并使其当前内力减少30%
-- lv1 釋放時若敵人身上有“蝶焰”效果，則該技能造成的傷害提升50%
-- lv2 釋放時若敵人處於被“血焰”狀態，則該技能造成的傷害翻倍且無視敵方免死效果
---@class W_HuDJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuDJ_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --伤害提升
    self.dmg1 = self:getParam(1) -- 寒星提升最终伤害
    self.dmg2 = self:getParam(2) -- 冰冻提升最终伤害
end

-- 敌人有冰冻无视敌方免死效果
function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skillConfig = attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill3" and victim ~= nil and victim.bufMgr then
        if victim.bufMgr:hasBufByTag("XueYan") then
            attackData.ignoreAvoidDeath = true
        end
        if self.player.skyStar and victim.bufMgr:hasBufByTag("W_HuDJ_skill0") then
            self.player.skyStar:triggerStart(attackData)
        end
    end
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local dmg = data["damage"]
    local killer = data["killer"]
    local skill = data.attackData["skillConfig"]
    local victim = data["victim"]
    if self.player:equal(killer) and skill ~= nil and skill.anim_name == "skill3" and victim ~= nil and victim.bufMgr then
        if self.dmg1 and victim.bufMgr:hasBufByTag("W_HuDJ_skill0") then
            data["damage"] = dmg + GlobalTools:Mul(dmg, self.dmg1)
        end
        if self.dmg2 and victim.bufMgr:hasBufByTag("XueYan") then
            data["damage"] = dmg + GlobalTools:Mul(dmg, self.dmg2)
        end
    end
end

--销毁
function M:destroy()
    M.super.destroy(self)
end
return M