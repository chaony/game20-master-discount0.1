--百花派在敌方战场上布下“狂野”场地6秒，处于狂野场地中的敌方角色每秒会受到100%攻击力的伤害，
--且每受到3次该技能的伤害后，会被禁锢2秒
--激活“寄生”之种的侠客，受治疗效果额外降低20%

---@class W_BaiHP_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiHP_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    -- 额外buff id
    self.addEnemyBuff = self:getParam(1)    -- Buff[] 额外buff
    
    EventDispatcher:registerEvent("add_W_BaiH_skill11", {self,self.addBuffHandler})
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then
        eventData.buff.player.bufMgr:addBufById(self.addEnemyBuff, self.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_BaiH_skill11", {self,self.addBuffHandler})
    M.super.destroy(self)
end


return M