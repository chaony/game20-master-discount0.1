--該技能只有在處於“魔流劍”狀態時才能使用；魔流劍釋放絕殺一擊，對敵人造成300%攻擊力的傷害並使其受到的伤害增加30%，持续8秒

---@class W_FengZH_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FengZH_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

end

function M:spawn()
    M.super.spawn(self)
    local skill3Item = self.player.plySkill:getSkillByName("skill3")
    if skill3Item ~= nil then
        self.skill3 = skill3Item.cur_skill_config.feature
    end
end

function M:canUse()
    return self.player.master == nil and self.skill3 and self.skill3.skill3_stage == 2
end

function M:dead(data)
    return M.super.dead(self, data)
end

return M
