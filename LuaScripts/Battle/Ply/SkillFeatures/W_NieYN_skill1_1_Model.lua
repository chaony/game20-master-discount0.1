-- 开始战斗时聂隐娘瞬间移动到攻击力最高的敌人身边，将敌人的魂魄刺出，造成200%的伤害。如果敌人为术士型敌人，则额外造成2秒的眩晕，并且在眩晕结束后的3秒内无法增加内力。
--伤害提高至240%
--无法增加内力的时间延长至5秒
--术士类型敌人被眩晕3秒
---@class W_NieYN_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_NieYN_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.roleType = self:getParam(1)--职业
    self.buffId = self:getParam(2)  -- 额外buff
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
end

function M:injureHandler(eventName, eventData)
    local victim = eventData.victim
    local killer = eventData.killer
    local skill = eventData.attackData.skillConfig

    if killer == self.player and skill ~= nil and skill == self.skill and victim.plyData.role_type == self.roleType then
        victim.bufMgr:addBufById(self.buffId,self.player,self.skill)
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M