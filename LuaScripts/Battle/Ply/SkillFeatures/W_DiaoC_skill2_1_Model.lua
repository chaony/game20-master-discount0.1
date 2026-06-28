-- 战斗中，当貂蝉受到致命伤害时，会免疫本次伤害并瞬移到我方随机一位男性角色身后，
--为自己和该角色恢复300%攻击力的血量，并使该角色为自己抵挡伤害2秒，该效果有12秒冷却时间
-- 触发该技能后，貂蝉还会为自己和该男性角色增加200点内力
---@class W_DiaoC_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiaoC_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className) 
    M.super.init(self, ply, skill,className)

    self.buffId1 = self:getParam(1)--buffid回血
    self.buffId2 = self:getParam(2)--抵挡伤害buffid
    self.cdTimes = self:getParam(3)--技能cd
    self.buffId3 = self:getParam(4)--回内buffid
    self.already = true;
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("PlayerAttackMove", {self,self.playerAttackMoveHandler})
end

function M:canUse()
    return false
end
-- 受男性角色伤害有减免
---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    -- 检查触发必死
    self:checkDead(eventData)
end

---@param eventData Battle_HandleData_Injure
function M:checkDead(eventData)
    if self.already then
        if self.player:equal(eventData.victim) then
            if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
                local evtFrame = self:getAttackMoveFrame()
                local targets = SelectTargetUtil:findPlayerByParam(self.player, {
                    camp = "friendExceptSelf",
                    ignoreSummon = true,
                    gender = "man",
                    count = "one",
                    priority = true,
                })
                if targets.Count > 0 then   -- 有男性角色
                    self.already = false
                    -- 免疫本次伤害
                    eventData.wantdata.damage = 0
                    -- 给自己加一个buff
                    self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
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
                target.bufMgr:addBufById(self.buffId1, self.player, self.skill)
                target.bufMgr:addBufById(self.buffId2, self.player, self.skill)
                target.bufMgr:addBufById(self.buffId3, self.player, self.skill)
                self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
                self.player.bufMgr:addBufById(self.buffId3, self.player, self.skill)
                -- 开始内部冷却
                TimeTools:delayTime(self.cdTimes, function()
                    self.already = true
                end)
            end
        end
    end
end

function M:getAttackMoveFrame()
    return self.player.evtMgr:getCommonEventByKey("AttackMove", 1)
end

function M:destroy()
    self.shareHurtTarget = nil
    EventDispatcher:unRegisterEvent("PlayerAttackMove", {self,self.playerAttackMoveHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end


return M