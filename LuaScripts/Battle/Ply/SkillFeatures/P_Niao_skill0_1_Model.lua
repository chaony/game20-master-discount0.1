--释放绝技时，羽毛数量再增加3根
---@class P_Niao_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Niao_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.extCount = self:getParam(1) -- x根羽毛
end

function M:destroy()
    M.super.destroy(self)
end

return M