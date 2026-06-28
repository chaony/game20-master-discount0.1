--  SP飞雪之怒：召唤幽灵飞雪到场上，飞雪会继承自身70%的属性，并一直存在到战斗结束，飞雪会对附近的敌人发起攻击，并且会分担九黎受到的50%伤害。在祈灵状态下，飞雪和九黎受到的伤害会降低40%，暴击率提高20%
--飞雪死亡时，九黎会获得3秒的无敌效果。
--当九黎受到致命伤害时，飞雪会代替九黎承受此次伤害，每10秒只能触发一次。
--飞雪死亡后，九黎会获得50%的攻击力加成，持续到战斗结束。
---@class W_JiuLSP_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuLSP_skill2_1_Model", SkillFeatures_Model)

M.summoned = nil

M.timer = 0
function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.attr = self:getParam(1)
    self.hurtShareBuff = self:getParam(2)--飞雪会对附近的敌人发起攻击，并且会分担九黎受到的50%伤害。
    self.lowInjureBuff = self:getParam(3)--在祈灵状态下，飞雪和九黎受到的伤害会降低40%，暴击率提高20%
    self.deadInvincibleBuff = self:getParam(4)--九黎会获得3秒的无敌效果。
    self.resistInjureTime = self:getParam(5)--飞雪会代替九黎承受此次伤害，每10秒只能触发一次。
    self.deadAttackBuff = self:getParam(6)-- 九黎会获得50%的攻击力加成，持续到战斗结束。

    self.spdBuff = 0
    self.canResistDeath = false
    self.hasResistDeath = false
    self.reCombatTime = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
    EventDispatcher:registerEvent("add_W_JiuLSP_skill3", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_JiuLSP_skill3", {self,self.removeBuffHandler})

end

function M:spawnFinish()
    M.super.spawnFinish(self)

    self.player.evtMgr:commonEventWork("Sendfor", 1)
    self.player.evtMgr:commonEventWork("Sendfor", 2)
    self.isActive = false

    self:askCatToTiger()
end

function M:spawn()
    M.super.spawn(self)
    if self.player.resonance ~= nil then
        local resonanceSkill0 = self.player.resonance:getSkill(1)
        if resonanceSkill0 ~= nil then
            self.attr = resonanceSkill0.attr
            self.spdBuff = resonanceSkill0.spdBuff
        end
        local resonanceSkill1 = self.player.resonance:getSkill(2)
        if resonanceSkill1 ~= nil then
            self.reCombatTime = resonanceSkill1.reCombatTime
        end
    end
end

--召唤成功
---@param data Battle_HandleData_SendForFinish
function M:sendForHandler( eventName, data )
    local player = data["player"]
    if self.player:equal(player.master) == true then
        player.data:copyData(self.player, true, self.attr)
        player.data:set_curHp(player.data:get_hp())
        player:ShowHpBar(false)
        if player.playerId == 8011 then
            self.summoned_cat = player
        elseif player.playerId == 8012 then
            self.summoned_tiger = player
            self.player.plyMgr:removePlayerFromList(self.summoned_tiger)
            self:showObj(self.summoned_tiger, false)
        end
    end
end

function M:askCatToTiger()
    if self.summoned_cat ~= nil then
        self.summoned_cat:lockEnemy(self.player:get_enemy())
        self.summoned_cat.aiEngine:changeState("skill", {animName = self.skill.anim_name})
    end
end

--变成虎状态
function M:changeToTiger()
    if self.isActive == false then
        self.isActive = true
        self.summoned_tiger.data:set_curHp(self.summoned_tiger.data:get_hp())
        self.summoned_tiger.bufMgr:addBufById(self.hurtShareBuff, self.player)
        if self.spdBuff > 0 then
            self.summoned_tiger.bufMgr:addBufById(self.spdBuff, self.player)
        end
        if self.player.bufMgr:hasBufByTag() then
            self.summoned_tiger.bufMgr:addBufById(self.lowInjureBuff, self.player)
        end
        if self.summoned_tiger.camp == 1 then
            self.player.plyMgr.hero_list:add(self.summoned_tiger)
        else
            self.player.plyMgr.enemy_list:add(self.summoned_tiger)
        end
        self.summoned_tiger:lockEnemy(self.summoned_cat:get_enemy())
        self.summoned_tiger:setPos(self.summoned_cat:get_position(), true)
        if self.summoned_tiger.aiEngine then
            self.summoned_tiger.aiEngine:changeState("idle")
        end
        self:showObj(self.summoned_cat, false)
        self:showObj(self.summoned_tiger, true)
        self.summoned_cat.bufMgr:destroy()
        self.summoned_tiger:ShowHpBar(true)
        self:connectTarget(self.summoned_tiger)
    end

end

--变成猫
function M:changeToCat()
    if self.isActive == true then
        self.isActive = false
        self:cancelConnectTarget()
        self.player.plyMgr:removePlayerFromList(self.summoned_tiger)
        self.summoned_tiger.bufMgr:clearBuf()
        if self.player:isLive() and self.player.bufMgr then
            if self.deadInvincibleBuff > 0 then
                self.player.bufMgr:addBufById(self.deadInvincibleBuff,self.player, self.skill)
            end
            if self.deadAttackBuff > 0 then
                self.player.bufMgr:addBufById(self.deadAttackBuff,self.player, self.skill)
            end
        else
            return
        end
        self.summoned_cat:setPos(self.summoned_tiger:get_position(), true)
        self.summoned_cat.aiEngine:changeState("idle")
        self:dispatchEvent_Local(Battle.SkillEventType.W_JiuLSP_LaoHu_Dead, {player = self.summoned_tiger})
        self.summoned_tiger:ShowHpBar(false)
        self:showObj(self.summoned_cat, true)
        self:showObj(self.summoned_tiger, false)
        self.summoned_tiger.bufMgr:destroy()
        local players = self.player.plyMgr:getPlayers(-self.summoned_cat:get_camp())
        for i=players.Count,1,-1 do
            local p = players:get(i-1)
            if self.summoned_cat:equal(p.enemy) == true or self.summoned_tiger:equal(p.enemy) == true then
                p:lockEnemy(nil);
            end
        end
        self.player.plyMgr:removePlayerFromList(self.summoned_cat)
        self.player.plyMgr.summon_list:add(self.summoned_cat)
        self.summoned_cat.summonData.follow = true

        if self.reCombatTime > 0 then
            TimeTools:delayTime(self.reCombatTime,function()
                if self.player:isLive() then
                    self:askCatToTiger()
                end
            end )
        end
    end
end


function M:showObj(player, show)
    local data = {}
    data.player = player
    data.show = show
    self:dispatchEvent_Local(Battle.SkillEventType.W_JiuLSP_Summon_ShowObj, data)
end

--技能事件
function M:skillDispatch(data)
    --猫技能回调
    if data.eventName == "skill2_active" then
        self:changeToTiger()
    end
end

function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) then
        if self.resistInjureTime > 0
                and not self.hasResistDeath
                and self.isActive
                and self.summoned_tiger
                and (self.canResistDeath or self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata)) then
            if not self.canResistDeath then
                self.canResistDeath = true
                TimeTools:delayTime(self.resistInjureTime,function()
                    self.hasResistDeath = true
                end )
            end

            eventData.wantdata.damage = 0   -- 免受本次伤害
            --老虎承受此次伤害
            local wantdata = {}
            wantdata["damage"]  = eventData.wantdata.damage
            wantdata["suck_value"] = GlobalTools.base0;
            local data = {}
            data["type"] = 3
            data["hitEffectList"] = eventData.attackData.hitEffectList
            self.summoned_tiger:beHitDirect(eventData.killer, data, wantdata, false, false)
        end
    end
end


function M:addBuffHandler(eventName, data)
    self.player.bufMgr:addBufById(self.lowInjureBuff,self.player,self.skill)
    if self.isActive and self.summoned_tiger ~= nil and self.summoned_tiger.bufMgr then
        self.summoned_tiger.bufMgr:addBufById(self.lowInjureBuff,self.player,self.skill)
    end
end

function M:removeBuffHandler(eventName, data)
    self.player.bufMgr:removeBufById(self.lowInjureBuff)
    if self.isActive and self.summoned_tiger ~= nil and self.summoned_tiger.bufMgr then
        self.summoned_tiger.bufMgr:removeBufById(self.lowInjureBuff)
    end
end

-- 连接
function M:connectTarget(target)
    if target and self.player:equal(target) ~= true then
        local hookData
        hookData = self.player.evtMgr:getCommonEventByKey("Hook", 1)
        if hookData then
            local lineData = table.copy(hookData.data)
            --加载预制
            self.line = require("Battle.Line.Line_Model").new()
            self.line:init(lineData, self.player, self.player, target)
            --将连线加入到管理器
            self.player.lineMgr:addLine(self.line)
            self.linkTarget = self.line.target
            -- target.bufMgr:addBufById(self.buffId1, self.player, self.skill)
            -- self.player.bufMgr:addBufById(self.buffId2, target, self.skill)
        end
    end
end

---@param deadPlayer PlayerModel
function M:cancelConnectTarget(deadPlayer)
    if self.line then
        self.player.lineMgr:removeLine(self.line)
        self.line:destroy()
        self.line = nil
    end
end


function M:destroy()
    self:cancelConnectTarget()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    EventDispatcher:unRegisterEvent("add_W_JiuLSP_skill3", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_JiuLSP_skill3", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M