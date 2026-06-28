---@class W_CangJ_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangJ_attack1_1_Model", SkillFeatures_Model)
--当前状态，1位重剑，2为轻剑

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

--技能释放
function M:skillStart(data)
    if self.skill3 ~= nil and self.skill3.state ~= nil and self.skill3.state ~= 0 then
        self.skill.extra_anim_name = "attack1_"..self.skill3.state
    else
        self.skill.extra_anim_name = "attack1_1"
    end
end

function M:destroy()
    M.super.destroy(self)
   
end
return M