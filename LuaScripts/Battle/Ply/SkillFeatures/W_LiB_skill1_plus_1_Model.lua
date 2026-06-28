--李白每次对敌人造成伤害时，都会为自身施加一层“诗仙”状态，诗仙状态也会被视为“诗气”状态，每层诗仙状态会使自身的外功伤害提升5%，最多叠加10层，
--当自身受到致命伤害时，若自身存在诗仙状态，则会消耗所有诗仙状态免疫本次伤害，使自身无敌2秒，
--且每有一层“诗仙”状态，都会为自身恢复5%最大生命值的血量，该效果有10秒冷却时间
--lv2 当诗仙状态叠加至5层时，李白造成的所有伤害都会无视敌方闪避值
--lv3 诗仙状态叠加至10层时，李白会在之后的5秒内无视敌方50%防御和伤害减免，该效果无法叠加
--lv4 战斗开始时，李白会获得3层“诗仙”状态
---@class W_LiB_skill1_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiB_skill1_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    for i = 1, 10 do
        self.buffEffectTab[i] = self:getParam(i) -- 诗气特效
    end
    self.buffId = self:getParam(11) --诗仙buf
    self.buffId2 = self:getParam(12) --无敌buf
    self.buffId3 = self:getParam(13) --回血buf
    self.cdTime = self:getParam(14)--冷却时间
    self.triggerNums = self:getParam(15)--状态叠加层数
    self.triggerNumsNoDef = self:getParam(16)--无视防御层数
    self.noDefTime = self:getParam(17)--触发无视防御层数
    self.noDefPer = self:getParam(18)--无视防御百分比
    self.noResatdPer = self:getParam(19)--无视伤害减免百分比
    self.startNums = self:getParam(20)--无视伤害减免百分比
    self.cdFlag = false
    self.noDefFlag = false
    EventDispatcher:registerEvent("add_W_LiB_skill1_plus", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("victimBeforeAttack", {self,self.victimBeforeAttack})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.startNums > 0 then
        for i = 1, self.startNums do
            self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
        end
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    local victim = eventData.victim
    local killer = eventData.killer
    local attackData = eventData.attackData
    if self.player:equal(killer) then
        self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
    elseif not self.cdFlag and self.player:equal(victim) and self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) and self.player.bufMgr:hasBufByTag("W_LiB_skill1_plus") then
        self.cdFlag = true
        eventData.wantdata.damage = GlobalTools.base0
        local buffs = self.player.bufMgr:findBufByTag("W_LiB_skill1_plus")
        for i = 1, #buffs do
            self.player.bufMgr:addBufById(self.buffId3, self.player, self.skill)
        end
        self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
        self.player.bufMgr:removeBufByTag("W_LiB_skill1_plus")
        self.player.bufMgr:removeBufByTag("W_LiB_skill1_plus_effect")
        TimeTools:delayTime(self.cdTime, function()
            self.cdFlag = false
        end)
    end
end

--作为受伤者的属性临时调整
---@param eventData Battle_HandleData_VictimBeforeAttack
function M:victimBeforeAttack(eventName, eventData)
    if self.triggerNums > 0 and self.player:equal(eventData.killer) then
        local buffs = self.player.bufMgr:findBufByTag("W_LiB_skill1_plus")
        if #buffs >= self.triggerNums then
            local oldDodge = eventData.victim.data.dodge:getValue()
            eventData.victim.data.dodge:addToAddListTemp(-oldDodge)
        end
        if self.noDefFlag and self.noResatdPer > 0 then
            eventData.victim.data.def:addToMulListTemp(GlobalTools.base1 - self.noDefPer)
            self.player.data.disres:addToAddListTemp(self.noResatdPer)
            self.player.data.disatd:addToAddListTemp(self.noResatdPer)
        end
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if  buff ~= nil and self.player:equal(buff.source)  then
        local buffs = self.player.bufMgr:findBufByTag("W_LiB_skill1_plus")
        local buff_nums = #buffs
        if self.buffEffectTab[buff_nums] then
            self.player.bufMgr:addBufById(self.buffEffectTab[buff_nums], self.player)
        end
        if self.triggerNumsNoDef > 0 and buff_nums >= self.triggerNumsNoDef and not self.noDefFlag then
            self.noDefFlag = true
            TimeTools:delayTime(self.noDefTime, function()
                self.noDefFlag = false
            end)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_LiB_skill1_plus", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("victimBeforeAttack", {self,self.victimBeforeAttack})
    M.super.destroy(self)
end

return M