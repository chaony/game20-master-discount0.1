--当自身存在鬼王状态时，自己的普通攻击会得到升级，变为召唤鬼王利爪，攻击范围内的所有敌人

---@class W_JiS_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiS_attack1_1_Model", SkillFeatures_Model)

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.player.bufMgr:hasBufByTag("JiS_skill3") then
        -- 鬼王状态转为群攻
        self.skill.extra_anim_name = "attack1_2"
    else
        self.skill.extra_anim_name = "attack1"
    end
end

return M