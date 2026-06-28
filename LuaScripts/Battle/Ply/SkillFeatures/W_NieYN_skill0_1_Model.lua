-- 聂隐娘受到来自术士职业的伤害时，有50%的概率免疫本次伤害。
--当受到致命伤害时，免疫本次伤害并判定，如果为内功伤害，则会立即回满生命值，并附带4秒无敌，如果为外功伤害，则附带1秒无敌（该效果每场战斗触发一次）。
--免疫伤害的概率提高到70%
--判定为内功伤害后，还会提高30%的攻击力直到战斗结束
--有60%的概率在受到来自术士的伤害后，使造成伤害的敌人受到双倍于本次伤害的伤害

---@class W_NieYN_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_NieYN_skill0_1_Model", SkillFeatures_Model)



function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.roleType = self:getParam(1)--职业
    self.unDeathRate = self:getParam(2)  -- 免死概率
    self.inBuffId = self:getParam(3)  -- 内功致死buffid
    self.outBuffId = self:getParam(4)  -- 外功致死buff
    self.reboundRate = self:getParam(5)  -- 反伤概率
    self.reboundMulty = self:getParam(6)  -- 反伤倍率

    self.hasUnDeath = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:spawn()
    M.super.spawn(self)
end

function M:injureHandler(eventName, eventData)
    if not self.player:equal(eventData.victim) then
        return
    end
    if eventData.killer.plyData.role_type == self.roleType then
        if GlobalTools:CheckRandom1(self.unDeathRate) then
            eventData.wantdata.avoidInure = true   -- 免受本次伤害
            return
        end
    end
    if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) and not self.hasUnDeath then
        self.hasUnDeath = true
        eventData.wantdata.avoidInure = true
        --eventData.wantdata.damage = 0   -- 免受本次伤害
        --伤害类型        --1 nei伤        --2 wai伤
        if eventData.attackData.damageType == 1 then
            self.player.bufMgr:addBufById(self.inBuffId, self.player, self.skill)
        else
            self.player.bufMgr:addBufById(self.outBuffId, self.player, self.skill)
        end
    end
    if self.reboundRate > 0 and eventData.wantdata.damage > 0 and eventData.killer.plyData.role_type == self.roleType and GlobalTools:CheckRandom1(self.reboundRate) then
        local rebound_damage = GlobalTools:Mul(eventData.wantdata.damage, self.reboundMulty)
        local attackData = BattleTool:getBaseAttackData()
        attackData["injureType"] = "skill"
        attackData["skillConfig"] = self.skill
        attackData["damage"] = rebound_damage
        attackData["player"] = self.player
        attackData["angerAir"] = GlobalTools.base1
        attackData["type"] = 3
        attackData["injureBuf"] = 0
        attackData["damageType"] = 1
        local wantdata = {}
        wantdata["damage"] = attackData["damage"]
        wantdata["suck_value"]  = 0
        eventData.killer:beHitDirect(self.player, attackData, wantdata, false, true)
    end

end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M