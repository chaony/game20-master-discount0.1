--受到来自于聂隐娘的伤害的敌方侠客会被沉默2s

---@class W_NieYN_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_NieYN_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.silenceBuff = self:getParam(1)
    EventDispatcher:registerEvent("injure", {self, self.injureHandler})
end

function M:injureHandler(eventName, eventData)
    local player = eventData["killer"]
    local victim = eventData["victim"]

    if player ~= nil and victim ~= nil and player:equal(self.player) then
        victim.bufMgr:addBufById(self.silenceBuff,self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end
return M;