-- 战斗中，潘金莲受到来自敌方一样角色的伤害减少40%，
-- 当自身受到致命伤害时，会立刻瞬移至己方生命值最高角色身边，使其在之后的5秒内，替自己承受伤害，该效果每场战斗只能触发一次
---@class W_PanJL_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_PanJL_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className) 
    M.super.init(self, ply, skill,className)

    self.resatdValue = self:getParam(1) -- Fix[0-1] 受敌方男性角色伤害减免
    self.addBuffId = self:getParam(2) -- Buff[] 给目标加的buff
    self.addSelfBuffId = self:getParam(3) -- Buff[] 给自己加的buff
    if self.resatdValue > GlobalTools.base1 then    -- 减伤不能超过百分百
        self.resatdValue = GlobalTools.base1
        Logger.logError("潘金莲减伤比例超过100")
    end

    -- 受男性角色真实受伤比例
    self.damageRate = GlobalTools.base1 - self.resatdValue
    -- 只能触发一次免疫
    self.isTrigger = false
    self.shareHurtTarget = nil -- 分摊潘金莲伤害的英雄

    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("PlayerAttackMove", {self,self.playerAttackMoveHandler})
    EventDispatcher:registerEvent("allInjure", {self,self.allInjureHandler})
end

-- 受男性角色伤害有减免
---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) then
        if eventData.killer and (eventData.killer.plyData.race == 5 or eventData.killer.plyData.race == 6)  then  -- 阴阳
            eventData.wantdata.damage = GlobalTools:Mul(eventData.wantdata.damage, self.damageRate)
            eventData.wantdata.damage = Mathf.Max(eventData.wantdata.damage, GlobalTools.base1)
        end
    end 
    
    -- 检查触发必死
    self:checkDead(eventData)
end

---@param eventData Battle_HandleData_Injure
function M:checkDead(eventData)
    if self.isTrigger == false then
        if self.player:equal(eventData.victim) then
            if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
                local evtFrame = self:getAttackMoveFrame()
                local targets = SelectTargetUtil:findPlayerByParam(self.player, {
                    camp = "friendExceptSelf",
                    ignoreSummon = true,
                    pos = "hpRateMax",
                })
                if targets.Count > 0 then   -- 有角色
                    self.isTrigger = true
                    -- 免疫本次伤害
                    eventData.wantdata.damage = 0
                    -- 给自己加一个buff
                    self.player.bufMgr:addBufById(self.addSelfBuffId, self.player, self.skill)
                    evtFrame:work()
                end
            end
        end
    end
end

---@param eventData Battle_HandleData_PlayerAttackMove
function M:playerAttackMoveHandler(eventName, eventData)
    if self.player:equal(eventData.move.move.player) then
        local evtFrame = self:getAttackMoveFrame()
        if eventData.move.move.count == evtFrame.data.count then    -- 同一个帧事件
            local target = eventData.move.move.target
            if target then
                self.shareHurtTarget = target
                target.bufMgr:addBufById(self.addBuffId, self.player, self.skill)
            end
        end
    end
end

function M:getAttackMoveFrame()
    return self.player.evtMgr:getCommonEventByKey("AttackMove", 1)
end

---@param eventData Battle_HandleData_Injure
function M:allInjureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) then
        if self.shareHurtTarget ~= nil and self.shareHurtTarget:isLive() then  -- 攻击方式男性
            local buffList = self.shareHurtTarget.bufMgr:findBufByTag("W_PanJL_skill0")
            if #buffList>0 then
                eventData.wantdata.damage = 0
            end
        end
    end
end

function M:destroy()
    self.shareHurtTarget = nil
    EventDispatcher:unRegisterEvent("allInjure", {self,self.allInjureHandler})
    EventDispatcher:unRegisterEvent("PlayerAttackMove", {self,self.playerAttackMoveHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end


return M