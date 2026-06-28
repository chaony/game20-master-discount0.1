-- 慈航造成的所有治疗效果提升15%
---@class W_CiH_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CiH_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureRate = self:getParam(1)
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player.data.cureRate:addToMulList(self.cureRate)
end

function M:destroy()
    M.super.destroy(self)
end

return M