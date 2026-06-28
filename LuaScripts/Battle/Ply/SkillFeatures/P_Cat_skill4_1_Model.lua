--内力恢复速率提升x%。若在斗气阶段胜出，内力恢复速率额外提升y%
---@class P_Cat_skill4_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Cat_skill4_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.battleWin = self.player.power_win == 1 -- 比斗气是否胜出
end

function M:skillStart(data)
    if self.battleWin then
        self.skill.extra_anim_name = "skill4_1"
    else
        self.skill.extra_anim_name = "skill4"
    end
    M.super.skillStart(self, data)
end

function M:destroy()
    M.super.destroy(self)
end

return M