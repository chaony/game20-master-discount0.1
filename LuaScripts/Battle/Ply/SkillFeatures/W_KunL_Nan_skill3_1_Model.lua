---@class W_KunL_Nan_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_KunL_Nan_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.player.hangupFollowOffset = FixVector3.New(0,0,0)
    self.player.hangupFollowOffset.z = -GlobalTools.base0_3
end

function M:canUse()
    return false
end

function M:destroy()
    M.super.destroy(self)
end

return M