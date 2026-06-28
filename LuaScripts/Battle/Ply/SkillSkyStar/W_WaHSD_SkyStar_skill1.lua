--残月·霜：
--由风晴雪造成的冰冻时间提升至4秒"

---@class W_WaHSD_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_WaHSD_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buffTime = self:getParam(1, 0)    --Buff[]
    EventDispatcher:registerEvent("add_W_WaHSD_BingD", {self,self.addBuffHandler})
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if self.player:equal(eventData.buff.source) and self.buffTime > 0 then
        eventData.buff:setCurLastTime(self.buffTime)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_WaHSD_BingD", {self,self.addBuffHandler})
    M.super.destroy(self)
end
return M;