--太乙：
--纯阳处于“人剑合一”状态时，攻击将无视敌方侠客的防御值，并可额外获得15%外伤加深

---@class W_JinG_ChunY_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_JinG_ChunY_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    self.extraBuff = self:getParam(1, 0)  --Buff[] 额外伤害加深buff
    
    EventDispatcher:registerEvent("injure", {self, self.injureHandler})
    self.isRunning = false
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.isRunning and self.player:equal(eventData.killer) then
        -- 无视敌方防御
        local def = eventData.victim.data.def:getValue()
        eventData.victim.data.def:addToAddListTemp(-def) -- 将防御将至0
    end
end

function M:triggerStart(data)
    self.player.bufMgr:addBufById(self.extraBuff, self.player)
    self.isRunning = true
end

function M:triggerEnd(data)
    self.player.bufMgr:removeBufById(self.extraBuff, true)
    self.isRunning = false
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_ChunY_RJHY", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_ChunY_RJHY", {self,self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end

return M;