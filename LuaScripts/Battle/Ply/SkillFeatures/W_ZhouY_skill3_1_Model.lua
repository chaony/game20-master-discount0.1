--周瑜施展烈火焚烧所有敌人，每秒对其造成140%攻击力的伤害，持续4秒，若命中的敌人身上有“引燃”或“焚烬”状态，则每次造成伤害时，
--还会额外造成1次爆炸，对范围内的敌人额外造成1次伤害（不会施加引燃）
--伤害提升至160%攻击力
--命中的敌人身上若有“焚烬”状态，则每次造成伤害还会使其眩晕1秒
--伤害提升至180%攻击力

---@class W_ZhouY_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhouY_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.fireBuff = self:getParam(1)--焚烧buff
    self.bombBuff = self:getParam(2)--额外爆炸buff
    self.imprisonBuff = self:getParam(3)--眩晕buff
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:injureHandler(eventName, eventData)
    local victim = eventData.victim
    local killer = eventData.killer
    local skill = eventData.attackData.skillConfig
    if  killer ~= nil and skill ~= nil and self.skill == skill and eventData.attackData.sourceBuff ~= nil and eventData.attackData.sourceBuff.buffId == self.fireBuff and self.player:equal(killer) and victim.bufMgr ~= nil  then
        local hasYinRan = victim.bufMgr:hasBufByTag("W_ZhouY_YinRan")
        local hasFenJin = victim.bufMgr:hasBufByTag("W_ZhouY_FenJin")
        if hasYinRan or hasFenJin then
            victim.bufMgr:addBufById(self.bombBuff, self.player,self.skill)
        end
        if self.imprisonBuff > 0 then
            victim.bufMgr:addBufById(self.imprisonBuff, self.player,self.skill)
        end
    end
end
function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
	M.super.destroy(self)
end

return M