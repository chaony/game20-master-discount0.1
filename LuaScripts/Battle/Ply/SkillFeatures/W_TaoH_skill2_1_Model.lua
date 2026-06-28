--战斗开始后,8秒内，桃花造成的所有伤害会无视敌人的防御
---@class W_TaoH_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaoH_skill2_1_Model", SkillFeatures_Model)

M.isWork = false

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.time = self:getParam(1)
    --0 不无视护盾 1 无视护盾
    self.wuseShield = self:getParam(2);
    --特效id
    self.effectBuff = self:getParam(3);
    
    self.timer = 0
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    self.timer = self.time
    self.isWork = true
    self.player.bufMgr:addBufById(self.effectBuff, self.player)
end

function M:update(dt)
    M.super.update(self, dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.isWork = false
            self.timer = 0;
        end
    end
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if self.isWork == true then
        attackData.ignoreGuard = (self.wuseShield == 1)
    end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
    M.super.killerDataChangeTemp(self, victim, skill)
    if self.isWork == true then
        victim.data.def:addToMulListTemp(-GlobalTools.base1)
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M