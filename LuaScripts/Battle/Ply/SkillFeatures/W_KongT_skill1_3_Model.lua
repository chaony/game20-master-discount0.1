--该技能造成伤害的30%会转化为自身血量
---@class W_KongT_skill1_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_KongT_skill1_3_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureRate = self:getParam(1)
end


function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if killer ~= nil and killer:equal(self.player) and skillConfig == self.skill then
        self.player:cure("fix", self.player, GlobalTools:Mul(dmg, self.cureRate), self.skill)
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M