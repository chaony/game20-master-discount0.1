---@class W_TianY_skill1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianY_skill1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.angerBuff = self:getParam(1)
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local attackData = data["attackData"]
    if ply ~= nil and attackData.skillConfig ~= nil and ply:equal(self.player) and attackData.skillConfig.anim_name == "skill1" then
        self.player.bufMgr:addBufById(self.angerBuff, self.player)
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M