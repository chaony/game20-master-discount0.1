--战斗开始15秒后，该SKILL1技能会替换为武则天的普攻
---@class W_WuZT_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuZT_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    ---@type PlayerSkillItem
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        self.skill1 = skill1.cur_skill_config.feature
    end
end

function M:spawnFinish()
    if self.player.skyStar then
        self.player.skyStar:triggerStart()
    end
end

-- 有技能1的状态普攻不可用
function M:canUse()
    if self.skill1 and self.skill1.changeAttack then
        return false
    end
    return true
end

function M:destroy()
    M.super.destroy(self)
end

return M