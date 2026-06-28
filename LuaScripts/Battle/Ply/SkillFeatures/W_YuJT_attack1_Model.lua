--当毁殇状态下，天墉城的普攻将变为玄天炽焰(设置普攻不可用)
---@class W_YuJT_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YuJT_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    ---@type PlayerSkillItem
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        ---@type SkillDataConfig
        self.skill1 = skill1.cur_skill_config
    end
end

-- 有技能3的状态普攻不可用
function M:canUse()
    if self.skill1 then
        return false
    end
    return true
end

function M:destroy()
    M.super.destroy(self)
end

return M