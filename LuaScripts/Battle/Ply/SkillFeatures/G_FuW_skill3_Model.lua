---@class G_FuW_skill3 : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("G_FuW_skill3", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        self.skill1 = skill1.cur_skill_config.feature
    end
end

function M:skillStart()
    if self.skill1 ~= nil and self.player.medCount ~= nil and self.player.medCount > 0 then
        self.skill1:setMed(self.player.medCount - 1)
        self.skill.extra_anim_name = "skill3_1"
    else
        self.skill.extra_anim_name = "skill3_2"
    end
end


function M:destroy()
    M.super.destroy(self)
end
return M