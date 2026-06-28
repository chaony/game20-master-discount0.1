--绝技持续期间，阿驼自身获得反伤效果,反弹受到伤害的65%(不是转移伤害)
---@class P_YangT_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_YangT_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData = self:getParam(1) -- 反伤效果
end

function M:destroy()
    M.super.destroy(self)
end

return M