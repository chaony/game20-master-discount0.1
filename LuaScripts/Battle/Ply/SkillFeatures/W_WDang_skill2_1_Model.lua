--向前释放一团真气球，真气球会持续向前飞行，当飞行到最远位置或碰到敌人时，真气球会爆炸，对范围内的敌人造成200%攻击力的伤害，该技能的伤害会随着飞行距离逐渐增大
---@class W_WDang_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WDang_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    --伤害提升的单位距离
    self.unitDistance = self:getParam(1)
    --单位距离提升的伤害
    self.damage = self:getParam(2)
    --能够提升的最大伤害
    self.maxDmg = self:getParam(3)
end

--子弹命中
function M:bulletHit(data)
    local bullet = data.bullet
    if bullet.sourceSkill ~= nil and bullet.sourceSkill.anim_name == "skill2" then
        if self.damage > GlobalTools.base0 then
            local dist = bullet.flyDistance
            local count = GlobalTools.base0
            while dist > self.unitDistance do
                count = count + GlobalTools.base1
                dist = dist - self.unitDistance
            end
            local damage = GlobalTools:Mul(count, self.damage)
            if damage > self.maxDmg then
                damage = self.maxDmg
            end
            damage = self:checkShield(bullet, damage)
            bullet.frontDamage = bullet.frontDamage + damage
        end
    end
end

function M:checkShield(bullet, damage)
    return damage
end

function M:destroy()
    M.super.destroy(self)
end
return M