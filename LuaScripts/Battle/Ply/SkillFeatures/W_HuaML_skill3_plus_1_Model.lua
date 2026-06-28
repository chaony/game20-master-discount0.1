--花木兰立即冲至当前血量最低的敌人身后，对其造成300%攻击的伤害，为其施加“xx”标记，持续5秒，之后使自身进入“xx”状态，持续5秒，
--xx状态持续期间花木兰会获得30%的攻击力和攻速提升，且除被施加了xx标记的敌人以为，其他所有敌人都无法对花木兰造成伤害，
--xx状态持续期间若敌人死亡，则xx标记会转移至另外一个随机敌人，持续时间保留
---@class W_HuaML_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuaML_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)--标记buff
    self.player.skill3ClearAnger = true
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("killPlayer", {self,self.killPlayerHandler})
    EventDispatcher:registerEvent("victimBeforeAddAnger", {self,self.addAngerHandler})
end

function M:skillStart(data)
    local enemies = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true, count = "all"})
    for i = enemies.Count, 1, -1 do
        local ememy = enemies:get(i - 1)
        if ememy and ememy.bufMgr then
            ememy.bufMgr:removeBufByTag("W_HuaML_skill3_plus")
        end
    end
end

function M:addAngerHandler(eventName, eventData)
    local killer = eventData.killer
    local victim = eventData.victim
    if self.player:equal(victim) then
        if self.player.bufMgr:hasBufByTag("W_HuaML_skill3_plus2") then
            if killer.bufMgr and not killer.bufMgr:hasBufByTag("W_HuaML_skill3_plus") then
                if eventData.angerTable and eventData.angerTable.anger then
                    eventData.angerTable.anger = GlobalTools.base0
                end
            end
        end
    end
end

function M:injureHandler(eventName, eventData)
    local killer = eventData.killer
    local victim = eventData.victim
    local attackData = eventData.attackData
    if self.player:equal(victim) then
        if self.player.bufMgr:hasBufByTag("W_HuaML_skill3_plus2") then
            if killer.bufMgr and not killer.bufMgr:hasBufByTag("W_HuaML_skill3_plus") then
                attackData.noAttack = true
                eventData.wantdata.damage= GlobalTools.base0
            end
        end
    end
end

function M:killPlayerHandler(eventName, data)
    local victim = data["victim"]
    if victim.camp ~= self.player.camp and self.player.bufMgr:hasBufByTag("W_HuaML_skill3_plus2") then
        local W_HuaML_skill3_plus = victim.bufMgr:findBufByTag("W_HuaML_skill3_plus")
        if table.nums(W_HuaML_skill3_plus) > 0 then
            local oldBuff = W_HuaML_skill3_plus[0]
            local target = SelectTargetUtil:findOneEnemy(self.player)
            if target and target.bufMgr and oldBuff then
                local buff = target.bufMgr:addBufById(self.buffId, self.player, self.skill)
                if buff then
                    buff.curLastTime = oldBuff.curLastTime
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("victimBeforeAddAnger", {self,self.addAngerHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killPlayerHandler})
    M.super.destroy(self)
end

return M