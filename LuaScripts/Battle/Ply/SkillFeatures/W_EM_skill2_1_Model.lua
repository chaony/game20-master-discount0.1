---@class W_EM_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_EM_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

--攻击开始处理
function M:beforeAttack(attackData, killer)
    local buff = self.player.bufMgr:findBufByTag("W_EM_skill2")
    if #buff > 0 then
        attackData["mustDodgeOut"] = true
    end
end

return M