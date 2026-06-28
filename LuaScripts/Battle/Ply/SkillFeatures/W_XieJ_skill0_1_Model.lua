-- 战斗开始时，邪极会携带一个傀儡，当自身受到致死伤害时，邪极会使用傀儡抵消本次伤害并无敌1秒，之后会恢复自身20%最大血量，
-- 每个傀儡在一场战斗中仅可抵消一次伤害

---@class W_XieJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XieJ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.buffId1 = self:getParam(1) -- Buff[] 无敌buff
    self.buffId2 = self:getParam(2) -- Buff[] 恢复生命buff
    self.summonLevel2 = self:getParam(3) -- int[0-50] 召唤傀儡2层数
    self.summonLevel3 = self:getParam(4) -- int[0-50] 召唤傀儡3层数

    self.curPuppetCnt = 0   -- 当前傀儡数量
    self.alreadyOffsetDamageCnt = 0     -- 当前已经抵挡伤害次数
    
    self.summonPuppets = {false, false, false}  -- 傀儡状态

    EventDispatcher:registerEvent("PlayerDead", {self, self.playerDeadHandle})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    self:summonPuppet(1, true)
end

function M:spawnFinish()
    self.mySkill1 = self.player.plySkill:getSkillByName("skill1")
    M.super.spawnFinish(self)
end

---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandle(eventName, eventData)
    if (not self.player:equal(eventData.data)) then  -- 非是自己死亡
        if self.skill:canUse() then
            if self.player.aiEngine ~= nil  then
                self.player.aiEngine.skillConfig = self.skill
                self.player.aiEngine:changeState("attack")
            end
        end
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.alreadyOffsetDamageCnt < self.curPuppetCnt then
        if self.player:equal(eventData.victim) then
            if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
                for i, v in ipairs(self.summonPuppets) do
                    if v == true then
                        self.summonPuppets[i] = false   -- 将其中一个傀儡置空
                        break
                    end
                end
                
                self.alreadyOffsetDamageCnt = self.alreadyOffsetDamageCnt + 1
                self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
                self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
                eventData.wantdata.damage = 0   -- 抵消本次伤害
                
                -- 通知视图层
                self:dispatchEvent_World(Battle.SkillEventType.MV_W_XieJ_Weapon_skill_Model_Puppet_Change, {
                    player = self.player, feature = self, summonPuppets = self.summonPuppets,
                })
            end
        end
    end
end

--- 召唤一个傀儡
function M:summonPuppet(index, notNotify)
    if self.summonPuppets[index] == true then
        Logger.logError(index,"邪极已经召唤了这个傀儡")
        return
    end
    self.curPuppetCnt = self.curPuppetCnt + 1
    self.summonPuppets[index] = true

    if not notNotify then
        -- 通知视图层
        self:dispatchEvent_World(Battle.SkillEventType.MV_W_XieJ_Weapon_skill_Model_Puppet_Change, {
            player = self.player, feature = self, summonPuppets = self.summonPuppets,
        })
    end
end

--- 是否召唤过这个傀儡
function M:haveSummonPuppet(index)
    return self.summonPuppets[index] == true
end

---@return W_XieJ_skill1_1_Model
function M:getSelfSkill1()
    if self.mySkill1 then
        return self.mySkill1.cur_skill_config and self.mySkill1.cur_skill_config.feature
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self, self.playerDeadHandle})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M