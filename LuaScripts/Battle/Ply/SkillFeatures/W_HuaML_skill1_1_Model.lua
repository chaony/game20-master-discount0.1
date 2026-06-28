--花木兰快速攻击当前目标三次，每次造成120%攻击力的伤害，最后一击还会额外附加5%敌方最大生命值的伤害并使其攻击力降低20%，持续5秒

---@class W_HuaML_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuaML_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, eventData)
    local killer = eventData.killer
    local victim = eventData.victim
    if killer ~= nil and self.player:equal(killer) then
        if BattleTool:isMySkillBuffByPlayer(self.player, eventData.attackData, killer, "W_HuaML_skill1") then
            if victim ~= nil and victim:isLive() and victim.isBoss == true then
                eventData.wantdata.damage = GlobalTools.base0
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end
return M