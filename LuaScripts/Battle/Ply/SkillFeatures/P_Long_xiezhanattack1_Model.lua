--龙分身普攻和真身不走一个
---@class P_Long_xiezhanattack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Long_xiezhanattack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:skillStart(data)
    if self.player.master ~= nil then
        self.skill.extra_anim_name = "xiezhanattack1_2"
    else
        self.skill.extra_anim_name = "xiezhanattack1"
    end
    M.super.skillStart(self, data)
end

function M:destroy()
    M.super.destroy(self)
end

return M