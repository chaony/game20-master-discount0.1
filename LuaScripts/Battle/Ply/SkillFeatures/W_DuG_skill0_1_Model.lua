--战斗中，当独孤从背后攻击敌人时，造成的所有伤害会提升30%，且每对同一名敌人普攻3次，下一次普攻便会瞬移至敌人身前绞杀敌人，对其造成200%攻击力的伤害并使其眩晕2秒；
--当独孤正面面对攻击目标时，会有50%的概率闪躲目标攻击

---@class W_DuG_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuG_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.upHurtRate = self:getParam(1) -- 背后提升伤害百分比
    self.attackNum = self:getParam(2) -- 普攻次数
    self.jiaoShaBuff = self:getParam(3) -- 绞杀buff
    self.frontDodgeRate = self:getParam(4) -- 正面闪避基础概率
    self.dodgeNum = self:getParam(5) -- 闪避值单位
    self.upDodgeRate = self:getParam(6) -- 提升闪避率
    self.maxDodgeRate = self:getParam(7) --闪避率上限
    self.rewardBuff = self:getParam(8) -- 杀敌后buff
    self.attackCount = 0 -- 连续背后普攻次数
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("victimBeforeAttack", {self,self.victimBeforeAttack})
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local attackData = data["attackData"]
    local victim = data["victim"]
    if self.player:equal(killer) and victim ~= nil then -- 造成伤害的是自己
        local forWard = BattleTool:checkPlayerAndTargetForward(self.player, victim)
        if forWard == false then -- 背对敌人
            data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(data.wantdata.damage, self.upHurtRate)
        end
        if attackData.skillConfig and attackData.skillConfig.anim_name == "attack1" then -- 造成普攻
            --if forWard == false then -- 背对敌人
                self.attackCount = self.attackCount + 1
                if self.attackCount == self.attackNum then
                    victim.bufMgr:addBufById(self.jiaoShaBuff, self.player)
                    self.attackCount = 0
                    if forWard == true then -- 面对敌人
                        self:skill2_move(victim)
                    end
                end
            --else
            --    self.attackCount = 0
            --end
        end
    end
end

-- 瞬移到敌人身后
function M:skill2_move(victim)
    if victim ~= nil then
        if victim:isLive() ~= true then
            victim = nil
        end
        if victim ~= nil and SceneManager.curScene.getAreaPosition ~= nil then
            local pos = victim:get_position() - victim:getForward() * GlobalTools.base1
            pos = SceneManager.curScene:getAreaPosition(pos)
            self.player:setPos(pos, true)
            BattleTool:safeTriggerActionEventWork(self.player, "skill1", "PlayEffect", 1)
        end
    end
end

--作为受伤者的属性临时调整
---@param eventData Battle_HandleData_VictimBeforeAttack
function M:victimBeforeAttack(eventName, eventData)
    if self.player:equal(eventData.victim) then
        local forWard = BattleTool:checkPlayerAndTargetForward(self.player, eventData.killer)
        if forWard == true then
            local dodge = self.frontDodgeRate
            local count =  GlobalTools:Div(self.player.data.dodge:getValue(), self.dodgeNum)
            if count > 0 then
                dodge = dodge + GlobalTools:Mul(count,self.upDodgeRate)
            end
            if self:checkDodge(math.min(dodge, self.maxDodgeRate)) then
                eventData.attackData.mustDodge = true
            end
        end
    end
end

function M:checkDodge(dodgeRate)
    if dodgeRate < GlobalTools.base100 then
        local r = WRandom:randomNum(0, 100)
        return r < dodgeRate
    end
    return true
end

---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandler(eventName, eventData)
    local ply = eventData["data"]
    if ply ~= nil and self.player:equal(ply) == false then
        if ply.killer ~= nil and ply.killer:equal(self.player) and self.player.bufMgr then
            self.player.bufMgr:addBufById(self.rewardBuff, self.player) -- 杀敌buff
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("victimBeforeAttack", {self,self.victimBeforeAttack})
    M.super.destroy(self)
end

return M