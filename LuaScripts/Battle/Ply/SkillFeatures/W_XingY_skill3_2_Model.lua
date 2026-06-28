---@class W_XingY_skill3_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XingY_skill3_2_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.equip_hero_id = 2059912
   
end

function M:destroy()
    M.super.destroy(self)
end

return M