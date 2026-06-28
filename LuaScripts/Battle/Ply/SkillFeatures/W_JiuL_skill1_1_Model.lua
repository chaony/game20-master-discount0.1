--对一名敌人造成200%攻击力的伤害和2s的眩晕。若释放时自身存在“祈灵”buff，则技能变为范围伤害；
---@class W_JiuL_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuL_skill1_1_Model", SkillFeatures_Model)

M.improve = false

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.range = self:getParam(1)
end

--技能释放,只有当前技能会调用
function M:skillStart(data)
    local buff = self.player.bufMgr:findBufByTag("W_JiuL_skill3")
    self.improve = #buff > 0
    if #buff > 0 then
        self.skill.extra_anim_name = "skill1_2"
    else
        self.skill.extra_anim_name = "skill1_1"
    end
end

return M