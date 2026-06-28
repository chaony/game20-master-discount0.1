-- 聂隐娘对当前敌人疯狂的挥舞鞭刃，造成8段伤害，每段150%攻击力，如果敌人当前的内力值低于30%，则会对所有敌人造成等额伤害。
--低于50%内力值时，即会对所有敌人造成伤害
--伤害提高至180%
--造成伤害时还会附带4秒眩晕
---@class W_NieYN_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_NieYN_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.innerRate = self:getParam(1)--低于x%内力值时，即会对所有敌人造成伤害
end

function M:skillStart(data)
    self.skill.extra_anim_name = "skill3"
    if self.player.enemy and self.player.enemy:isLive() and self.player.enemy.data:get_AngerRate() < self.innerRate then
        self.skill.extra_anim_name = "skill3_1"
    end
    M.super.skillStart(self, data)
end
function M:destroy()
    M.super.destroy(self)
end

return M