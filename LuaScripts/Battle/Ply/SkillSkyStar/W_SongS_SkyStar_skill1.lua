--烛阴功：
--嵩山对被冰冻的敌人额外造成20%伤害，并且当嵩山释放玄冥真气时，立即释放一次寒冰神掌。

---@class W_SongS_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_SongS_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)

    self.extraDamage = self:getParam(1, 0)   --Fix[0, 100] -- 额外造成伤害
    EventDispatcher:registerEvent("injure", {self, self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.killer) then
        if eventData.victim and eventData.victim.bufMgr:hasBufByTag("BingDong") then
            eventData.attackData.damageLast = eventData.attackData.damageLast + self.extraDamage
        end 
    end
end

---@field 触发冰冻
function M:triggerStart(feature)
    if self.player:isLive() then
        self.player.evtMgr:triggerActionEventWork("skill1", "Hit", 1)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end

return M;