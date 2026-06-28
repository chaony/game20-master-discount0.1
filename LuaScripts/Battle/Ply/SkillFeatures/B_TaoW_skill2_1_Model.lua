--战斗中，boss自身受到的单体伤害增加50%

---@class B_TaoW_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_TaoW_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.isFive = self:getParam(1) --第五形态
end

function M:skillStart(data)
    if self.isFive == 1 then
        self.skill.extra_anim_name = "skill2_1"
    else
        self.skill.extra_anim_name = "skill2"
    end
end
function M:destroy()
    M.super.destroy(self)
end

return M