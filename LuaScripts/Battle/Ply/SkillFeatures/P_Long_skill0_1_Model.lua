--释放绝技后，自身进入火怒状态，状态持续8s,加个Buff
---@class P_Long_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Long_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData = self:getParam(1)
end

function M:destroy()
    M.super.destroy(self)
end

return M