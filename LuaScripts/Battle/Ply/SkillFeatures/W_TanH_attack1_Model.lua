---@class W_TanH_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TanH_attack1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end


function M:spawn()
    M.super.spawn(self)
    self.skill1 = self.player.plySkill:getSkillByName("skill1")
end


function M:canUse()
    if  self.skill1 ~= nil then
        return false
    end
    return true
end

return M