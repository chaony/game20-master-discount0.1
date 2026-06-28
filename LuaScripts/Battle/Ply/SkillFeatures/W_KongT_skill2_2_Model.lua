--该技能每命中一个敌人，崆峒便获得一层持续5秒的护盾，每层护盾可抵挡100%攻击力的伤害
---@class W_KongT_skill2_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_KongT_skill2_2_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buff = self:getParam(1)
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
        self.player.bufMgr:addBufById(self.buff, self.player)
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M