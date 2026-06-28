---@class W_TianY_skill0_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianY_skill0_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
    self.maxCount = self:getParam(2)
end


function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if ply ~= nil and ply:equal(self.player) then
        local buff = victim.bufMgr:findBufByTag("W_TianY_skill0")
        if table.nums(buff) < self.maxCount then
            victim.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M