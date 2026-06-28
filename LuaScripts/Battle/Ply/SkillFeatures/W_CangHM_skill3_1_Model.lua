--苍火门为随机三个敌人施加“苍火印”，苍火印会在施加两秒后爆炸，对周围的敌人造成200%攻击力的范围伤害，
--若敌方已经被施加了苍火印记或者血量低于30%，则苍火印会立刻爆炸

---@class W_CangHM_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangHM_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.lowHpRate = self:getParam(1)       -- Fix[0-100]  低于百分比血量
    self.increasesDamage = self:getParam(2)       -- Fix[0-1]  增伤百分比
    self.chyBuff = self:getParam(3)       -- Buff[0-1]  苍火印buff
    
    EventDispatcher:registerEvent("add_W_CangHM_CHY", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then     -- 自己加的buff
        local target = eventData.buff.player
        -- 符合条件立刻爆炸
        if target and target.data:get_hpRate() <= self.lowHpRate or #target.bufMgr:findBufByTag("W_CangHM_CHY") >= 2 then
            eventData.buff:addTriggerTag("CangHM_Immediately")
            eventData.buff:triggerBuffImmediately(true, false)
        end
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.killer) then
        local attackData = eventData.attackData
        if attackData  then
            local buff = attackData.sourceBuff
            if buff and buff.sourceBuff and buff.sourceBuff:haveTriggerTag("CangHM_Immediately") and buff:checkTag("W_CangHM_Boom") then
                -- 增伤
                eventData.wantdata.damage = eventData.wantdata.damage + GlobalTools:Mul(eventData.wantdata.damage, self.increasesDamage) 
            end
        end
    end
end

function M:killerAfterAttack(data)
    if self.player:equal(data.killer) then
        if BattleTool:attackDataHaveExtraParam(data.attackData, "AddCHY") then
            data.victim.bufMgr:addBufById(self.chyBuff, self.player, data.attackData.skillConfig)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_CangHM_CHY", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M
