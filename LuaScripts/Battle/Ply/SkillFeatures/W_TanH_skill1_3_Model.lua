-- 探花的普攻现在不会被闪避，击杀敌人后，普攻CD减半,持续5秒
local W_TanH_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_TanH_skill1_1_Model")

---@class W_TanH_skill1_3_Model : W_TanH_skill1_1_Model @
---@field super W_TanH_skill1_1_Model @W_TanH_skill1_1_Model
local M = class("W_TanH_skill1_3_Model", W_TanH_skill1_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.intervalAfterKiller = self:getParam(4)             -- Fix[0-10]击杀后蓄力时间
    self.intervalAfterKillerContinue = self:getParam(5)     -- Fix[0-10]击杀后蓄力时间减少的持续时间
    self.continueTimer = 0
    self.mustHit = true
    self.isKillerIntervalTimer = false
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end


function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skill  = attackData.skillConfig
    if skill ~= nil and skill.anim_name == "skill1" then
        attackData.mustHit = self.mustHit
    end
end

---@param eventData Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, eventData)
    if self.continueTimer <= 0 and self.player:equal(eventData.killer) then -- 自己击杀
        self.continueTimer = self.intervalAfterKillerContinue
        self.currentInterval = self.intervalAfterKiller
        if not self.isKillerIntervalTimer then
            -- 蓄力时间减少后 把当前的蓄力时间也减少
            self:tryCastAttackSkillAfterDt(Mathf.Max(self.interval - self.currentInterval, 0))
            self:dispatchEvent_Local(Battle.SkillEventType.MV_W_TanH_skill1_1_Model_RefreshEffect, {})
        end
    end
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    if self.continueTimer > 0 then
        self.continueTimer = self.continueTimer - dt
        if self.continueTimer <= 0 then
            self.currentInterval = self.interval
            if self.isKillerIntervalTimer then
                -- 蓄力时间增加后 把当前的蓄力时间也增加
                self.timer = self.timer + Mathf.Max(self.interval - self.intervalAfterKiller, 0)
                self:dispatchEvent_Local(Battle.SkillEventType.MV_W_TanH_skill1_1_Model_RefreshEffect, {})
            end
        end
    end
end

function M:startAttackInterval()
    self.isKillerIntervalTimer = self.continueTimer > 0
    M.super.startAttackInterval(self)
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end
return M