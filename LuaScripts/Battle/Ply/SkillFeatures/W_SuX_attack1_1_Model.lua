--且普攻会得到升级，每次普攻时都会对周围大范围内的敌人造成伤害

---@class W_SuX_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_SuX_attack1_1_Model", SkillFeatures_Model)

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.player.bufMgr:hasBufByTag("SuX_skill3") then
        self.skill.anim_name = "skill3_attack"
    else
        self.skill.anim_name = "attack1"
    end
end

return M