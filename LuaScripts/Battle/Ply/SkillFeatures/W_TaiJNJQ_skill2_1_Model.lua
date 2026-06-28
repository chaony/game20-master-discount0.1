--当阵图处于极阳状态时，太极内家拳会为所有施加了极阳之力的己方侠客施展恢复效果，为其恢复100%攻击的血量，和50点内力；
--当阵图处于极阴状态时，太极内家拳会对所有施加了极阴之力的敌方侠客造成3段，每段80%攻击力的内功伤害
--lv4 伤害提升至120%，且必定触发极阴印记的爆炸效果
---@class W_TaiJNJQ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiJNJQ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.isMustBoom = self:getParam(1) -- 
end

function M:spawn()
    M.super.spawn(self)
    self.skill1 = BattleTool:getSkillFeatureByName(self.player, "skill1_plus")
    if self.skill1 == nil then
        self.skill1 = BattleTool:getSkillFeatureByName(self.player, "skill1")
    end
end

function M:skillStart(data)
    if self.skill1 then
        if self.skill1.curStatus == 2 then
            self.skill.extra_anim_name = "skill2_1"
        else
            self.skill.extra_anim_name = "skill2"
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M