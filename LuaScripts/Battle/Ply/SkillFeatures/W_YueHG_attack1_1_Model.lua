--
---@class W_YueHG_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YueHG_attack1_1_Model", SkillFeatures_Model)

function M:spawn()
    local skill3Item = self.player.plySkill:getSkillByName("skill3") 
    if skill3Item ~= nil then
        self.skill3 = skill3Item.cur_skill_config.feature
    end
    M.super.spawn(self)
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.skill3 and self.skill3.skill_state == 1 then
        self.skill.extra_anim_name = "attack2"
    else
        self.skill.extra_anim_name = "attack1"
    end
end

return M