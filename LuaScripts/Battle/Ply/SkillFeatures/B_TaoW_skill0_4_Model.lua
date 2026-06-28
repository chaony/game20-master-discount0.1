--战斗中，boss自身受到的群体体伤害增加50%
local B_TaoW_skill0_1_Model = require("Battle.Ply.SkillFeatures.B_TaoW_skill0_1_Model")
---@class B_TaoW_skill0_4_Model : B_TaoW_skill0_1_Model @
---@field super B_TaoW_skill0_1_Model @B_TaoW_skill0_1_Model
local M = class("B_TaoW_skill0_4_Model", B_TaoW_skill0_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.addHurtRate = self:getParam(2) -- 
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    if self.isFive == 1 then
        self.player.bufMgr:addBufById(self.addHurtRate, self.player, self.skill)
    end
end

function M:injureHandler(eventName, data)
    local victim = data["victim"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if victim ~= nil and victim:equal(self.player)then
        if self.isFive == 0 and data["attackData"] and data["attackData"]["isSingleTarget"] == false then
            data["wantdata"]["damage"] = dmg + GlobalTools:Mul(dmg, self.addHurtRate)
        elseif self.isFive == 1 and data["attackData"] and data["attackData"].isCrit == true then
            data["wantdata"]["damage"] = dmg + GlobalTools:Mul(dmg, self.addHurtRate)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M