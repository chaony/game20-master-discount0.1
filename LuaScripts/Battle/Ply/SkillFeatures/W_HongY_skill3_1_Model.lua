--红衣发射信号弹召唤远程炮队,对大范围内敌人造成共计4次伤害,每次100%攻击力，该技能会对破甲状态下的敌人造成更多伤害
---@class W_HongY_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HongY_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.level1 = self:getParam(1)
    self.rate1 = self:getParam(2)
    self.level2 = self:getParam(3)
    self.rate2 = self:getParam(4)
    self.level3 = self:getParam(5)
    self.rate3 = self:getParam(6)
    self.level4 = self:getParam(7)
    self.rate4 = self:getParam(8)
    self.level5 = self:getParam(9)
    self.rate5 = self:getParam(10)
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local skill = data.attackData.skillConfig
    local damage = data.damage
    local victim = data.victim
    if skill ~= nil and skill == self.skill and data.attackData.injureType ~= "dot" then
        local buff = victim.bufMgr:findBufByTag("pojia")
        if #buff > 0 then
            data.damage = damage + GlobalTools:Mul(damage, self:getRate(#buff))
        end
    end
end

--获取当前层数对应的提升
function M:getRate(count)
    for i = 1, 5 do
        if count <= self["level"..i] then
            return self["rate"..i]
        end
    end
    return 0
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    self.targetPos = nil
end

--范围hit攻击调整攻击中心点
function M:checkAoeTarget(targetPos)
    if self.targetPos == nil then
        self.targetPos = targetPos
        return targetPos
    else
        return self.targetPos
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M