--若释放时，若自身的“薰风”效果已经叠加至上限，则恢复的血量翻倍

---@class W_SuX_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill0 W_SuX_skill0_1_Model
local M = class("W_SuX_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.addCure = self:getParam(1)  -- Fix[]恢复血量增加百分比
end

function M:spawn()
    M.super.spawn(self)

    self.skill0 = BattleTool:getSkillFeatureByName(self.player,"skill0")
end

-- 治疗效果翻倍
function M:victimDataChangeTemp(killer, skill)
    if self.skill == skill and self.skill0 and self.skill0:hasMaxXunFengBuff() then
        if self.addCure > 0 then
            killer.data.cureRate:addToMAAListTemp(self.addCure, "skill_extra")
        end
    end
end

return M