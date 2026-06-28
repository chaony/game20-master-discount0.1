--sp九黎猫
---@class W_JiuLSP_Cat_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuLSP_Cat_attack1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:spawn()
end

--角色死亡
function M:dead(data)
    return M.super:dead(data)
end

function M:destroy()
    M.super.destroy(self)
end

return M