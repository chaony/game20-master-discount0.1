--六翼刀法·貳式命中敌人后会降低敌方50%被治疗效果持续5秒

---@class W_YuRFJ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_YuRFJ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buffId = self:getParam(1)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if BattleTool:isMySkillWithPlayer(self.player, eventData.attackData, "skill2") then    -- 是本技能2造成的伤害
        eventData.victim.bufMgr:addBufById(self.buffId, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M;