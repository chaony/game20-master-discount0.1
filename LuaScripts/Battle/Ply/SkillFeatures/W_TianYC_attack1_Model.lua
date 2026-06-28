--当毁殇状态下，天墉城的普攻将变为玄天炽焰(设置普攻不可用)
---@class W_TianYC_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianYC_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    ---@type PlayerSkillItem
    local skill3 = self.player.plySkill:getSkillByName("skill3")
    if skill3 ~= nil then
        ---@type SkillDataConfig
        self.skill3 = skill3.cur_skill_config
    end
end

-- 有技能3的状态普攻不可用
function M:canUse()
    local W_TianYC_skill3 = self.player.bufMgr:findBufByTag("W_TianYC_skill3")
    if table.nums(W_TianYC_skill3) > 0 and self.skill3.level >= 4 then
        return false
    end
    return true
end

function M:destroy()
    M.super.destroy(self)
end

return M