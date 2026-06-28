--吕布挥动方天画戟，对身前范围内的敌人造成150%攻击力的伤害，该技能造成伤害的30%会转化为自身恢复效果

---@class W_LvB_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LvB_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureRate = self:getParam(1)  --int 治疗效果百分比
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
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M