--开局获得持续5秒的5%伤害加深，持续8s。若在气势阶段比拼胜利后，第二阶段战斗开始获得10%伤害加深，效果持续8s
---@class P_Long_skill4_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Long_skill4_1_Model", SkillFeatures_Model)

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