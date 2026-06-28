-- 蝴蝶君每次普攻命中敵人時，會為其施加一層“蝶焰”效果

---@class W_HuDJ_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuDJ_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:skillStart(data)
    --local skill0 = self:getSkill1()
    --if (skill0 and skill0.actionChange == 1) then    -- 寒星buff动作替换
    --    self.skill.extra_anim_name = "attack1_1"
    --else
    --    self.skill.extra_anim_name = "attack1"
    --end
    M.super.skillStart(self, data)
end

---@return W_HuDJ_skill0_1_Model
function M:getSkill1()
    if not self.skill0 then
        self.skill0 = self:getSkillFeature("skill0")
    end
    return self.skill0
end

return M