--战斗开始时，关羽会获得10层“忠义”效果，每层“忠义”效果会使自身受到的的伤害减少5%，当任意友方侠客受到致命伤害时，关羽便会消耗自身所有“忠义”层数，
--每消耗一层忠义层数，便会使该队友恢复5%最大生命值的血量和0.5秒的无敌效果，该效果有10秒的冷却时间，只要关羽身上存在“忠义”buff，就不会被魅惑
---@class W_GuanY_skill2_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanY_skill2_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffTab = {}
    for i = 1, 10 do
        self.buffTab[i] = self:getParam(i)
    end
    self.zhongyiBuff = self:getParam(11)
    self.startNums = self:getParam(12)
    self.cureBuff = self:getParam(13)
    self.wudiBuff = self:getParam(14)
    self.triggerCd = self:getParam(15)
    self.killAddNums = self:getParam(16, 0)
    self.defBuff = self:getParam(17)
    self.curTimes = 0
    self.isTrigger = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:registerEvent("add_debuff", {self,self.addBuffHandler})
    --EventDispatcher:registerEvent("add_W_GuanY_skill2_plus", {self,self.addBuffHandler2})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    for i = 1, self.startNums do
        self.player.bufMgr:addBufById(self.zhongyiBuff, self.player, self.skill)
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if eventData.victim and eventData.victim.bufMgr and eventData.victim.master == nil and eventData.victim.camp == self.player.camp then
        if eventData.victim:isAttackCauseDeath(eventData.attackData, eventData.wantdata)  then
            if self.player.bufMgr:hasBufByTag("W_GuanY_skill2_plus") then
                eventData.wantdata.damage = 0   -- 免受本次伤害
                self.isTrigger = true
                local buffs = self.player.bufMgr:findBufByTag("W_GuanY_skill2_plus")
                local buffNums = table.nums(buffs)
                for i = 1, buffNums do
                    eventData.victim.bufMgr:addBufById(self.cureBuff, self.player, self.skill)
                    self.player.bufMgr:addBufById(self.defBuff, self.player, self.skill)
                end
                local buff = eventData.victim.bufMgr:addBufById(self.wudiBuff, self.player, self.skill)
                if buff then
                    local curLastTime = buff.lastTime
                    buff:addLastTime(GlobalTools:Mul(curLastTime, GlobalTools:ToFix(buffNums)))
                end
                
                self.player.bufMgr:removeBufByTag("W_GuanY_skill2_plus", false)
                TimeTools:delayTime(self.triggerCd, function()
                    self.isTrigger = false
                end)
            end
        end
    end
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if victim and self.player.camp == data.victim.camp and not self.player:equal(victim) then
        local killAddNums = self.killAddNums
        for i = 1, killAddNums do
            self.player.bufMgr:addBufById(self.zhongyiBuff, self.player, self.skill)
        end
    end
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.player) and buff.type == "Charm" then
        if self.player.bufMgr:hasBufByTag("W_GuanY_skill2_plus") then
            self.player.bufMgr:removeBuf(buff, true)
            --self.player.bufMgr:removeBufByTag("W_GuanY_skill2_plus", true)
        end
    end
end

--function M:addBuffHandler2(eventName, data)
--    local buff = data["buff"]
--    if buff ~= nil and self.player:equal(buff.player)  then
--        local buffs = self.player.bufMgr:findBufByTag("W_GuanY_skill2_plus")
--        local buffNums = table.nums(buffs)
--        local buffId = self.buffTab[buffNums] and self.buffTab[buffNums] or self.buffTab[1]
--        self.player.bufMgr:addBufById(buffId, self.player, self.skill)
--    end
--end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:unRegisterEvent("add_debuff", {self,self.addBuffHandler})
    --EventDispatcher:unRegisterEvent("add_W_GuanY_skill2_plus", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M