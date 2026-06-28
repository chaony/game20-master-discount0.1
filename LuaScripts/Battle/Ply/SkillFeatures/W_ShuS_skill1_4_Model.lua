-- lv4该技能现在造成的伤害将必定暴击
local W_ShuS_skill1_2_Model = require("Battle.Ply.SkillFeatures.W_ShuS_skill1_2_Model")

---@class W_ShuS_skill1_4_Model : W_ShuS_skill1_2_Model @
---@field super W_ShuS_skill1_2_Model @W_ShuS_skill1_2_Model
local M = class("W_ShuS_skill1_4_Model", W_ShuS_skill1_2_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    if attackData.skillConfig == self.skill then
        -- 必定暴击
        attackData.mustCrit = true
        M.super.killerBeforeAttack(self, attackData, victim)
    end
end

return M