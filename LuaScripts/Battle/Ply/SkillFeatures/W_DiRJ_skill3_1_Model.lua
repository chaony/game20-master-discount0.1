-- 狄仁杰先为所有敌方侠客施加一层断狱状态，随后对其断罪，根据敌人身上的断狱状态层数获得不同的效果；
--笞刑（1层）：对其造成200%攻击力的伤害，且在之后的6秒内，“断狱”造成的伤害增加效果翻倍；
--杖刑（2层）：对其造成200%的伤害，并使其眩晕2秒，且在之后的6秒内，“断狱”的伤害增加效果翻倍
--斩立决（3层）：对其造成200%的伤害，使其眩晕2秒，并为其额外增加一层“斩立决”状态，持续6秒，该状态下，“断狱”造成的伤害增加效果翻倍，且造成的伤害减少50%，攻速减少50%，若敌人在“斩立决”状态下生命值低于5%，则会立即死亡，无视免死效果；
---@class W_DiRJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiRJ_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    for i = 1, 3 do
        self.buffEffectTab[i] = self:getParam(i)
    end
    self.buffId1 = self:getParam(4) --断狱buff
    self.addNums = self:getParam(5) --一层断狱buff
    self.buffBian = self:getParam(6)--笞刑
    self.buffZhang = self:getParam(7)--杖刑
    self.buffZhan = self:getParam(8)--斩立决 
    self.deathHpRate = self:getParam(9)--即死百分比
    self.baseHurtRate = self:getParam(10)--伤害加深
    self.doubleTime = self:getParam(11)--双倍持续时间
    self.isInDouble = false
    EventDispatcher:registerEvent("add_W_DiRJ_skill1", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("selfHp", {self,self.conditionHandler})
    EventDispatcher:registerEvent("SkillEnter", {self,self.skillEnterHandler})
end

---@param eventData Battle_HandleData_SkillEnter
function M:skillEnterHandler(eventName, eventData)
    if self.player:equal(eventData.player) and eventData.skillConfig and eventData.skillConfig.anim_name == "skill3" then
        local enemies = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true, count = "all"})
        for i = 1, enemies.Count do
            local ememy = enemies:get(i - 1)
            if ememy and ememy.bufMgr then
                for nums = 1, self.addNums do
                    ememy.bufMgr:addBufById(self.buffId1, self.player, self.skill)
                end
            end
        end
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill3_shifang" then
        local enemies = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true, count = "all"})
        for i = 1, enemies.Count do
            local ememy = enemies:get(i - 1)
            if ememy and ememy.bufMgr then
                local buffs = ememy.bufMgr:findBufByTag("W_DiRJ_skill1")
                local buffNums = #buffs
                if buffNums == 1 then
                    ememy.bufMgr:addBufById(self.buffBian, self.player, self.skill)
                elseif buffNums == 2 then
                    ememy.bufMgr:addBufById(self.buffZhang, self.player, self.skill)
                elseif buffNums >= 3 then
                    ememy.bufMgr:addBufById(self.buffZhan, self.player, self.skill)
                end
            end
        end
        self.isInDouble = true
        TimeTools:delayTime(self.doubleTime, function()
            self.isInDouble = false
        end)
    end
end

--攻击者的攻击开始处理
---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    if self.isInDouble and victim and victim.bufMgr then
        local buffs = victim.bufMgr:findBufByTag("W_DiRJ_skill1")
        local buffNums = #buffs
        local addHurtRate = 0
        for i = 1, buffNums do
            addHurtRate = addHurtRate + self.baseHurtRate
        end
        attackData.damage = attackData.damage + GlobalTools:Mul(attackData.damage, addHurtRate)
    end
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local target = buff.player
        if target and target.bufMgr then
            local buffs = target.bufMgr:findBufByTag("W_DiRJ_skill1")
            local buffNums = #buffs
            buffNums = buffNums > #(self.buffEffectTab) and #(self.buffEffectTab) or buffNums
            if self.buffEffectTab[buffNums] then
                target.bufMgr:removeBufByTag("W_DiRJ_skill3_effect", true)
                target.bufMgr:addBufById(self.buffEffectTab[buffNums], self.player, self.skill)
            end
        end
    end
end

function M:hitFrame(frameData, data)
    if frameData.evtAction.animName == "skill3" and self.player:equal(frameData.player and frameData.player.master) then
        -- 改为范围攻击
        --data = table.copy(data)
        --data.count.count = "all"
        --data.count.camp = "enemy"
        --data.count.area = "rectangle"
        --data.count.areaWidth = self.attackAreaWidth
        --data.count.areaHeight = self.attackAreaHeight
    end
    return data
end

--条件触发
function M:conditionHandler( eventName, data )
    local player = data["ply"]
    if self.deathHpRate > 0 and not(player.isBoss) and player.data:get_hpRate() < self.deathHpRate and player:isLive() and player.bufMgr then
        local buffs = player.bufMgr:findBufByTag("W_DiRJ_skill3")
        if #buffs > 0 then
            player:realDead()
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_DiRJ_skill1", {self, self.addBuffHandler})
    EventDispatcher:unRegisterEvent("selfHp", {self,self.conditionHandler})
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.skillEnterHandler})
    M.super.destroy(self)
end

return M