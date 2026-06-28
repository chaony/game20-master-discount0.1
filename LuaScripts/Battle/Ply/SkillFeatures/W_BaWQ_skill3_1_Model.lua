-- 霸王枪挥动画卷将距离自己最远敌人拉至与自己相对的位置(面前4米,所有人都小于4米就不拉人了)，
-- 随后消耗n个枪头施展回马枪，对其造成350%攻击力的伤害,每消耗一个枪头,恢复自身100%攻击力的血量

---@class W_BaWQ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaWQ_skill3_2_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.afterDamageAddValue = self:getParam(1)   -- int[0-200] 少于n个枪头获伤害加成（后置伤害）
    self.addResLvUp = self:getParam(2)   -- buff[] 强化技能击杀后恢复枪头数量
    self.angerDeBuff = self:getParam(3)   -- buff[] 内力降低buf(持续999)
    self.debuffAddTime = self:getParam(4)   -- int[1-5] 消耗1个枪头buf增加N秒,
    self.upSkillCnt = self:getParam(5)   -- int[0-5] 强化技能条件枪头数(小于等于)]
    self.maxCostLv = self:getParam(6)   -- int[0-10] 释放必杀消耗枪头上限
    self.hpRecoverBuff = self:getParam(7)   -- buff[] 消耗枪头回血比例


    EventDispatcher:registerEvent("addLine", {self, self.addLineHandler})
end

function M:spawnFinish()
    self:getSkill1()
    M.super.spawnFinish(self)
end

function M:onSkillCostResLv(costLv)
    for i = 1, costLv do
        self.player.bufMgr:addBufById(self.hpRecoverBuff, self.player, self.skill)
    end
end

---@param eventData Battle_HandleData_AddLine
function M:addLineHandler(eventName, eventData)
    if eventData.line and self.player:equal(eventData.line.lineStartPlayer) then
        self.curSkillTarget = eventData.line.target        
    end
end

--- 强制打连线的目标
function M:findPlayer(data)
    if self.player.curSkillConfig == self.skill then
        if self.curSkillTarget and self.curSkillTarget:isLive() then
            data:clear()
            data:add(self.curSkillTarget)
        end
    end
    return data
end

function M:skillEnd(data)
    self.curSkillTarget = nil
    M.super.skillEnd(self, data)
end

---@return W_BaWQ_skill1_3_Model
function M:getSkill1()
    if not self.skill1 then
        self.skill1 = self:getSkillFeature("skill1")
    end
    return self.skill1
end

function M:destroy()
    EventDispatcher:unRegisterEvent("addLine", {self, self.addLineHandler})
    M.super.destroy(self)
end

return M
