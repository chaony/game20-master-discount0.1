--探花的普攻威力提升至600%攻击力，暴击伤害提升50%，但每次普攻之前都需要蓄力8秒
---@class W_TanH_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TanH_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.interval = self:getParam(1)
    self.crit = self:getParam(2)
    self.buffId = self:getParam(3)
    self.timer = GlobalTools.base0;
    
    self.currentInterval = self.interval
    self.canAttack = false
    
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    --EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
    --EventDispatcher:registerEvent("removeBuff", {self,self.removeBuffHandler})
    self.skill2 = self.player.plySkill:getSkillByName("skill2")
end

function M:spawn()
    M.super.spawn(self)
    self.skill2 = self.player.plySkill:getSkillByName("skill2")
    self.timer = self.interval
    self:addBuff(true)
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    self:startAttackInterval()
end

--显示特效
function M:showEffect( show )
    local data = { show = show }
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_TanH_skill1_1_Model_ShowEffect, data)
end


--技能开始，结束蓄力计时
---SkillEnterHandler
---@param eventName string
---@param data Battle_HandleData_SkillEnter
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local skill  = data["skillConfig"]
    if self.player:equal(ply) then
        if skill ~= nil and skill.anim_name == "skill1" then
            self.timer = GlobalTools.base0;
            self:addBuff(false)
            self:showEffect(false) 
        end
    end
end

--技能结束，开始蓄力计时
function M:SkillEndHandler(eventName, data)
    local ply = data["player"]
    local skill  = data["skillConfig"]
    if self.player:equal(ply) then
        if skill ~= nil and skill.anim_name == "skill1" then
            if self.skill2 ~= nil and self.skill2.cur_skill_config ~= nil then
                self.skill2.cur_skill_config.feature:use()
            end 
        end
        self:tryCastAttackSkillAfterDt(0)
    end
end

-- 开始蓄力
function M:startAttackInterval()
    self.timer = self.currentInterval
    self:showEffect(true)
end

----眩晕，打断buff会打断蓄力
--function M:addBuffHandler(eventName, data)
--    local buff = data["buff"]
--    if buff ~= nil and self.player:equal(buff.player) then
--        if buff.type == "Imprison" or buff.type == "Break" then
--            self.timer = 0
--            self:addBuff(false)
--            self:showEffect(false) 
--        end
--    end
--end
--
----眩晕，打断buff结束会重新开始蓄力
--function M:removeBuffHandler(eventName, data)
--    local buff = data["buff"]
--    if buff ~= nil and self.player:equal(buff.player) then
--        if buff.type == "Imprison" or buff.type == "Break" then
--            self.timer = self.interval
--            self:addBuff(true)
--            self:showEffect(true)
--        end
--    end
--end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    self:tryCastAttackSkillAfterDt(dt)
end

-- 蓄力技术释放技能
function M:tryCastAttackSkillAfterDt(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= GlobalTools.base0 then
            self.canAttack = true
        end
    end


    if self.player.curSkillConfig == nil then      -- 释放攻击不打断现有技能
        if self.canAttack then  -- 释放攻击
            self.canAttack = false
            self.player.aiEngine.skillConfig = self.skill
            self.player.aiEngine:changeState("attack")
        elseif self.timer <= 0 then -- 开始蓄力
            self:addBuff(true)
            self:startAttackInterval()
        end
    end
end

function M:addBuff(show)
    if show == true then
        self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
    else
        self.player.bufMgr:removeBufById(self.buffId)
    end
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if self.skill2 ~= nil and self.skill2.cur_skill_config ~= nil and self.skill2.cur_skill_config.feature.isImprove == true then
        local skill  = attackData.skillConfig
        if skill ~= nil and skill.anim_name == "skill1" then
            attackData.ignoreGuard = true
            if self.skill2.cur_skill_config.feature.armorBreak == true then
                attackData.armorBreak = true
            end
        end
    end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
    M.super.killerDataChangeTemp(self, victim, skill)
    if skill ~= nil and string.match(skill.anim_name, "skill1") then
        self.player.data.crit:addToAddListTemp(self.crit)
        if self.skill2 ~= nil and self.skill2.cur_skill_config ~= nil and self.skill2.cur_skill_config.feature.isImprove == true then
            self.player.data.critrate:addToAddListTemp(self.skill2.cur_skill_config.feature.critrate)
            self.player.data.physicaldamage:addToMulListTemp(self.skill2.cur_skill_config.feature.dmg)
            self.player.data.magicdamage:addToMulListTemp(self.skill2.cur_skill_config.feature.dmg)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    --EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    --EventDispatcher:unRegisterEvent("removeBuff", {self,self.removeBuffHandler})
end
return M