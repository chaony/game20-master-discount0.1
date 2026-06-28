--对一名敌人造成150%攻击力的外功伤害，该技能造成伤害的60%会转化为自身血量
---@class W_XueD_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XueD_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureRate = self:getParam(1)
end


function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:skillDispatch(data)
    if data.eventName == "cureHp" then
        self:hpHandle(data)
    end
end


function M:hpHandle(data)
    local frame = data.frame
    if frame.player:equal(self.player) then
        if self.dmg ~= nil then
            self.player:cure("fix", self.player, GlobalTools:Mul( self.dmg, self.cureRate), self.skill)
            self.dmg = nil
        end
    end
end


function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    if killer ~= nil and killer:equal(self.player) and skillConfig == self.skill then
        self.dmg = wantdata["damage"]
    end
end


function M:skillEnd()
   self.dmg = nil
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M