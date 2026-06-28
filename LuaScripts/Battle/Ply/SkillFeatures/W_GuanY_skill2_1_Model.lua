--战斗开始，关羽会获得10层“武圣”效果，每层“武圣”效果，会使自身攻击力增加5%，攻击速度增加5%，当关羽受到致命伤害时，会消耗自身所有“武圣”效果，
--每层武圣效果会为自身提供1秒无敌效果，一场战斗仅能触发一次
---@class W_GuanY_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanY_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffTab = {}
    for i = 1, 10 do
        self.buffTab[i] = self:getParam(i)
    end
    self.wushengBuff = self:getParam(11)
    self.startNums = self:getParam(12)
    self.wudiBuff = self:getParam(13)
    self.killAddNums = self:getParam(14, 0)
    self.atkBuff = self:getParam(15)
    self.curTimes = 0
    self.isTrigger = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    --EventDispatcher:registerEvent("add_W_GuanY_skill2", {self,self.addBuffHandler2})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    for i = 1, self.startNums do
        self.player.bufMgr:addBufById(self.wushengBuff, self.player, self.skill)
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) and not self.isTrigger then
        if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata)  then
            if self.player.bufMgr:hasBufByTag("W_GuanY_skill2") then
                eventData.wantdata.damage = 0   -- 免受本次伤害
                self.isTrigger = true
                local buffs = self.player.bufMgr:findBufByTag("W_GuanY_skill2")
                for i = 1, table.nums(buffs) do
                    self.player.bufMgr:addBufById(self.wudiBuff, self.player, self.skill)
                    self.player.bufMgr:addBufById(self.atkBuff, self.player, self.skill)
                end
                self.player.bufMgr:removeBufByTag("W_GuanY_skill2", false)
            end
        end
    end
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if victim and self.player.camp ~= data.victim.camp then
        local killAddNums = self.killAddNums
        if self.player:equal(killer) then
            killAddNums = killAddNums * 2
        end
        for i = 1, killAddNums do
            self.player.bufMgr:addBufById(self.wushengBuff, self.player, self.skill)
        end
    end
end

--function M:addBuffHandler2(eventName, data)
    --local buff = data["buff"]
    --if buff ~= nil and self.player:equal(buff.player)  then
    --    local buffs = self.player.bufMgr:findBufByTag("W_GuanY_skill2")
    --    local buffNums = table.nums(buffs)
    --    local buffId = self.buffTab[buffNums] and self.buffTab[buffNums] or self.buffTab[1]
    --    self.player.bufMgr:addBufById(buffId, self.player, self.skill)
    --end
--end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    --EventDispatcher:unRegisterEvent("add_W_GuanY_skill2", {self,self.addBuffHandler2})
    M.super.destroy(self)
end

return M