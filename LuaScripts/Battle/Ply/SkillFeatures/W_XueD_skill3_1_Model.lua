--血刀在自己身周围布下存在5秒的结界，当自己处于结界中时，会获得60%的伤害减免效果。
--结界存在期间，每秒会对范围内的敌人造成120%攻击力的外功伤害，该技能造成伤害的30%
--会在技能结束时转化为自身血量
---@class W_XueD_skill3_1_Model : SkillFeatures_Model
local M = class("W_XueD_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureRate = self:getParam(1)
    self.damage = GlobalTools.base0
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("remove_W_XueD_skill3", {self,self.removeBuffHandler})
end

function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if killer ~= nil and killer:equal(self.player) and skillConfig == self.skill then
        self.damage = self.damage + dmg
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        self.player:cure("fix", self.player, GlobalTools:Mul(self.damage, self.cureRate), self.skill)
        self.damage = GlobalTools.base0;
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("remove_W_XueD_skill3", {self,self.removeBuffHandler})
end

return M