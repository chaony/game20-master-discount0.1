---@class W_XieJ_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XieJ_attack1_1_Model", SkillFeatures_Model)

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.player.plyType == "W_XieJ2" then
        self.player.evtMgr:commonEventWork( "Sendfor", 2)
    else
        self.player.evtMgr:commonEventWork( "Sendfor", 1)    
    end
end

return M