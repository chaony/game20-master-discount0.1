
---@class B_TaoW_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_TaoW_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.isFive = self:getParam(1) --第五形态
end

function M:skillStart(data)
    if self.isFive == 0 then
        self.skill.extra_anim_name = "skill1"
    else
        self.skill.extra_anim_name = "skill1_1"
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M