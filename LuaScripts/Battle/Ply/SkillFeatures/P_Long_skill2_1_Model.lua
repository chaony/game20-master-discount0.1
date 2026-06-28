--被挂上火种的单位攻速减少10%
---@class P_Long_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Long_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData1 = self:getParam(1) -- 伤害加深
end

function M:destroy()
    M.super.destroy(self)
end

return M