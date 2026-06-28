--展昭进入“剑花”状态8秒，期间会闪避所有外功伤害，且会将受到伤害值的60%返还给攻击者
---@class W_ZhanZ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhanZ_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData = self:getParam(1) --免疫控制buff
    self.noHurt1 = self:getParam(2) --免疫外功伤害比例
    self.returnHurtRate = self:getParam(3) --返还比例
    self.noHurt2 = self:getParam(4) --免疫内功伤害比例
    self.enterSkill3 = false
    --EventDispatcher:registerEvent("victimBeforeAttack", {self,self.victimBeforeAttack})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:update(dt)
    M.super.update(self, dt)
    if self.player.animator ~= nil and self.player.animator.curState ~= nil and self.player.animator.curState.name == "skill3_loop" then
        if not self.player.bufMgr:hasBufByTag("W_ZhanZ_skill3") or self.player:isLive() ~= true  then
            self.player.animator:changeState("skill3_end")
            self.enterSkill3 = false
        end
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill3_addBuff" then
        self.enterSkill3 = true
        self.player.bufMgr:addBufById(self.buffData, self.player) --免疫控制buff
    end
end
---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    local attackType = data["attackData"]["type"]
    local attackData = data["attackData"]
    if self.enterSkill3 and self.player:equal(victim) and self.player.bufMgr:hasBufByTag("W_ZhanZ_skill3") then
        --伤害类型
        --1 nei伤
        --2 wai伤
        local origin_damage = data.wantdata.damage
        local rebound_damage = GlobalTools:Mul(origin_damage, self.returnHurtRate)
        if attackData.damageType == 1 then
            data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(self.noHurt2, data.wantdata.damage)
        elseif attackData.damageType == 2 then
            data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(self.noHurt1, data.wantdata.damage)
        end
        if rebound_damage > 0 then
            if killer ~= nil and killer.data:checkInvincible(0) == true then
                return
            end
            if killer ~= nil and attackType ~= 3 then
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
                killer:beHitDirect(self.player, attackData, wantdata, false, true)
            end
        end
    end
end

---@param eventData Battle_HandleData_VictimBeforeAttack
function M:victimBeforeAttack(killer, victim, attackData)
    if self.player:equal(eventData.victim) then
        --伤害类型
        --1 nei伤
        --2 wai伤
        if attackData.damageType == 1 then
            
        elseif attackData.damageType == 2 then
        
        end
    end
end
function M:destroy()
    self.enterSkill3 = nil
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M