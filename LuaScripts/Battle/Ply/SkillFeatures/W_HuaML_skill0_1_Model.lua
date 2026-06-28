-- 战斗中，花木兰每次对同一目标造成伤害时，便会为自身增加一层“xx”效果（这里文案给个名字），持续8秒，每层xx效果会为自身增加10%攻击力和10点坚韧值，最多6层；
--lv2 当花木兰受到致命伤害时，会立即消耗自身所有的“xx”效果，每消耗一层变为自身恢复10%最大生命值的血量和1秒无敌效果，该效果每场战斗仅能触发一次
---@class W_HuaML_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuaML_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffId1 = self:getParam(1)
    self.cureBuff = self:getParam(2)
    self.startNums = self:getParam(3)
    self.lastTarget = nil
    self.isTrigger = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.startNums > 0 then
        for i = 1, self.startNums do
            self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
        end
    end
end

function M:injureHandler(eventName, eventData)
    local killer = eventData.killer
    local victim = eventData.victim
    if self.player:equal(killer) then
        if self.lastTarget and self.lastTarget:equal(victim) then
            self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
        end
        self.lastTarget = victim
    elseif self.skill.level > 1 and not self.isTrigger and self.player:equal(victim) then
        if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
            if self.player.bufMgr:hasBufByTag("W_HuaML_skill0") then
                eventData.wantdata.damage = GlobalTools.base0  -- 免受本次伤害
                self.isTrigger = true
                local buffs = self.player.bufMgr:findBufByTag("W_HuaML_skill0")
                for i = 1, table.nums(buffs) do
                    self.player.bufMgr:addBufById(self.cureBuff, self.player, self.skill)
                end
                self.player.bufMgr:removeBufByTag("W_HuaML_skill0", false)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M