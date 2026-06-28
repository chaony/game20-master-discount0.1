--当阵图为极阳状态时，太极内家拳会为所有施加了极阳之力的己方侠客释放一个持续5秒的极阳盾，极阳盾会吸收角色所受伤害的20%并转化为极阳值，
--当护盾消失时，会产生爆炸，对周围敌人造成相当于极阳值20%的内功伤害；
--当阵图为极阴状态时，太极内家拳会为所有施加了极阴之力的敌方侠客施展一个持续5秒的极阴印记，
--当被施加了极阴印记的敌方侠客受到攻击时，极阴印记会有15%的概率爆炸，额外造成一次敌方最大生命值5%的真实伤害，最高不超过太极内家拳攻击力的300%,每五秒触发一次
---@class W_TaiJNJQ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiJNJQ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.reduceDamagePer = self:getParam(1) -- 吸收伤害百分比
    self.transDamagePer = self:getParam(2) --转换伤害百分比
    self.yangDamageBuff = self:getParam(3)
    self.boomRate = self:getParam(4)
    self.boomBuff = self:getParam(5)
    self.boomMaxDamagePer = self:getParam(6)
    self.boomCd = self:getParam(7) --
    self.skillTargets = {}
    self.boomTargets = {}
    EventDispatcher:registerEvent("add_W_TaiJNJQ_shiled", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_TaiJNJQ_shiled", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    M.super.spawn(self)
    self.skill1 = BattleTool:getSkillFeatureByName(self.player, "skill1_plus")
    if self.skill1 == nil then
        self.skill1 = BattleTool:getSkillFeatureByName(self.player, "skill1")
    end
    self.skill2 = BattleTool:getSkillFeatureByName(self.player, "skill2")
    self.skill3_plus = BattleTool:getSkillFeatureByName(self.player, "skill3_plus")
end

function M:skillStart(data)
    if self.skill1 then
        if self.skill1.curStatus == 2 then
            self.skill.extra_anim_name = "skill0_1"
        else
            self.skill.extra_anim_name = "skill0"
        end
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then     -- 自己加的buff
        local target = eventData.buff.player
        self.skillTargets[target] = 0
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    local victim = eventData.victim
    local killer = eventData.killer
    if victim and victim.bufMgr and self.player:equal(killer) then
        local isYinBoom = false
        local mustBoom = false
        local range = self.boomRate
        if BattleTool:isMySkillBuff(self, eventData.attackData, "W_TaiJNJQ_shiled_damage") and self.skillTargets[victim] then -- 极阳盾造成的伤害
            eventData.wantdata.damage = GlobalTools:Mul(self.skillTargets[victim], self.transDamagePer)
            self.skillTargets[victim] = 0
        elseif BattleTool:isMySkillBuff(self, eventData.attackData, "W_TaiJNJQ_yin_boom") then -- 极阴印记造成的爆炸伤害
            local atk = self.player.data.atk:getValue()
            local damageLimit = GlobalTools:Mul(atk, self.boomMaxDamagePer)
            if eventData.wantdata.damage > damageLimit then
                eventData.wantdata.damage = damageLimit
            end
            isYinBoom = true
        elseif BattleTool:isMySkillWithPlayer(self.player, eventData.attackData, "skill2") then    -- 是本技能2造成的伤害
            if self.skill2 and self.skill2.isMustBoom == 1 then
                mustBoom = true
            end
        elseif BattleTool:isMySkillWithPlayer(self.player, eventData.attackData, "skill3_plus") then   
            if self.skill3_plus and self.skill3_plus.boomRate  then
                range = self.skill3_plus.boomRate
            end
        end
        if not isYinBoom and victim.bufMgr:hasBufByTag("W_TaiJNJQ_yin_tag") then
            if not self.boomTargets[victim] then
                self.boomTargets[victim] = 0
            end
            if mustBoom or (self.boomTargets[victim] <= 0 and GlobalTools:CheckRandom1(range)) then
                victim.bufMgr:addBufById(self.boomBuff, self.player, self.skill)
                if self.player.skyStar then
                    self.player.skyStar:triggerStart(victim)
                end
                self.boomTargets[victim] = self.boomCd > 0 and self.boomCd or GlobalTools.base1
                TimeTools:delayTime(self.boomTargets[victim], function()
                    self.boomTargets[victim] = 0
                end)
            end
        end
    elseif victim and victim.bufMgr and victim.camp == self.player.camp and victim.bufMgr:hasBufByTag("W_TaiJNJQ_shiled") then --计算吸收的纯阳值
        if self.skillTargets[victim] == nil then
            self.skillTargets[victim] = 0
        end
        local recordDamage = GlobalTools:Mul(self.reduceDamagePer, eventData.wantdata.damage)
        self.skillTargets[victim] = self.skillTargets[victim] + recordDamage
        eventData.wantdata.damage = eventData.wantdata.damage - recordDamage
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local player = buff.player
        if player and player.bufMgr then
            player.bufMgr:addBufById(self.yangDamageBuff, self.player, self.skill)
        end
    end
end

function M:destroy()
    self.skillTargets = {}
    EventDispatcher:unRegisterEvent("add_W_TaiJNJQ_shiled", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_TaiJNJQ_shiled", {self,self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M