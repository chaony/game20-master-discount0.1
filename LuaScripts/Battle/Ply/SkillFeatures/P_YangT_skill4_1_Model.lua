--阿驼的普攻会附带20%概率的晕眩，持续2秒。在斗气阶段胜利后，晕眩概率额外提升10%
---@class P_YangT_skill4_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_YangT_skill4_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.battleWin = self.player.power_win == 1 -- 比斗气是否胜出
    self.bufId = self:getParam(1)
    self.imprisonCondition = self:getParam(2)
    self.imprisonConditionExtra = self:getParam(3)
end

--function M:skillStart(data)
--    if self.battleWin then
--        self.skill.extra_anim_name = "skill4_1"
--    else
--        self.skill.extra_anim_name = "skill4"
--    end
--    M.super.skillStart(self, data)
--end

function M:destroy()
    M.super.destroy(self)
end

return M