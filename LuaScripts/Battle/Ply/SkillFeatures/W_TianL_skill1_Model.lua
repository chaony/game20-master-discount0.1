---@class W_TianL_skill1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianL_skill1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.repeatCount = 1
    self.dodgeSuccess = false;
    self.count = 0;
end


function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("dodge", {self,self.dodgeHandler})
end


function M:dodgeHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    if killer ~= nil and killer:equal(self.player) then
        if self.player:get_curSkillConfig() == self.skill then
            self.dodgeSuccess = true
        end
    end
end


--技能结束
function M:skillEnd()
    if self.dodgeSuccess == true and self.count < self.repeatCount then
        self.count = self.count + 1
        if  self.player.aiEngine ~= nil then
            self.player.aiEngine.skillConfig = self.skill
        end
        -- 
        return "attack"
    end
    self.dodgeSuccess = false
    self.count = 0
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("dodge", {self,self.dodgeHandler})
end

return M