---@class W_XiaoY_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoY_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    local skill3 = self.player.plySkill:getSkillByName("skill3")
    if skill3 ~= nil then
        self.skill3 = skill3.cur_skill_config.feature
    end
end

--技能释放,只有当前技能会调用
function M:skillStart(data)
    if self.skill3 == nil then
        return
    end
    if self.skill3 ~= nil and self.skill3.state == 2 then
        self.skill.extra_anim_name = "skill3_attack"
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M