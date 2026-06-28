--为一名血量最低的敌方单位施加一个“苍火印”，
--若该技能成功击杀了敌人，则受到该次苍火印伤害的敌人都会被施加一个苍火印

---@class W_CangHM_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill3 W_CangHM_skill3_1_Model
local M = class("W_CangHM_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.targetHpRate = self:getParam(1)     --Fix[0-100] 敌人血量比例上限
    self.hpRateSegment = self:getParam(2)     --Fix[0-100] 敌人血量比例分段
    self.addDamage = self:getParam(3)     --Fix[0-100] 苍火印伤害提升比例
    self.maxLevel = self:getParam(4)     --Fix[0-10] 苍火印伤害提升最大层数
    self.addBuff5 = self:getParam(5)     --Buff[] 参与击杀敌人后自己加buff
    
    self.cacheHurtPlayerId = {}
    self.isKillPlayer = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("remove_W_CangHM_Boom", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

---@param data Battle_EventData_KillPlayer
function M:killPlayer(data)
    if BattleTool:isMySkillBuff(self, data.attackData, "W_CangHM_Boom") then -- 本技能杀死人
        self.isKillPlayer = true
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if BattleTool:isMySkillBuff(self, eventData.attackData, "W_CangHM_Boom") then -- 本技能杀死人
        table.insert(self.cacheHurtPlayerId, eventData.victim:get_playerInstanceId())
        -- 根据敌方生命比例进行增伤
        local hpRate = eventData.victim.data:get_hpRate()
        local upCnt = 0
        local addDamage = 0
        while hpRate < self.targetHpRate do
            hpRate = hpRate + self.hpRateSegment
            addDamage = addDamage + self.addDamage
            upCnt = upCnt + 1
            if upCnt >= self.maxLevel then
                break
            end
        end
        if not eventData.attackData.damageLast then
            eventData.attackData.damageLast = 0
        end
        eventData.attackData.damageLast = eventData.attackData.damageLast + addDamage
    end
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    self.cacheHurtPlayerId = {}
end

---@param eventData Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, eventData)
    if BattleTool:isKillerAssistance(self.player, eventData.victim) then
        self.player.bufMgr:addBufById(self.addBuff5, self.player, self.skill)
    end
end

---@param eventData Battle_HandleData_RemoveBuff
function M:removeBuffHandler(eventName, eventData)
    if eventData.buff and eventData.buff.sourceSkill == self.skill then
        if self.isKillPlayer then
            local chyBuff = self:getCangHYBuff()
            local targetList = table.unique(self.cacheHurtPlayerId)     -- 去重
            for i, v in ipairs(targetList) do
                local target = self.player.plyMgr:getPlayerByInstanceId(v)
                if target then    -- 已经死亡的角色不会再加buff
                    target.bufMgr:addBufById(chyBuff, self.player, self.skill)
                end
            end
        end
        self.isKillPlayer = false
    end
end

function M:getCangHYBuff()
    if not self.skill3 then
        local skill3 = self.player.plySkill:getSkillByName("skill3")
        if skill3 and skill3.cur_skill_config then
            self.skill3 = skill3.cur_skill_config.feature
        end
    end
    return self.skill3 and self.skill3.chyBuff
end

function M:destroy()
    self.cacheHurtPlayerId = {}
    EventDispatcher:registerEvent("remove_W_CangHM_Boom", {self,self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M
