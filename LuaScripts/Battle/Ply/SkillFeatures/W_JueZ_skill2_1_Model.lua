--普通攻击时有50%的概率为箭矢附加火焰，额外附加100%的伤害
---@class W_JueZ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JueZ_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.prop = self:getParam(1)
end


return M