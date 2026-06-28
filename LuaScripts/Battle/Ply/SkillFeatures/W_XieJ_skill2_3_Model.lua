-- lv3 当自身的“邪灵”效果累计了5层及以上时，该技能造成的伤害效果额外提升25%

local W_XieJ_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_XieJ_skill2_1_Model")

---@class W_XieJ_skill2_3_Model : W_XieJ_skill2_1_Model @
---@field super W_XieJ_skill2_1_Model @W_XieJ_skill2_1_Model
local M = class("W_XieJ_Weapon_skill2_3_Model", W_XieJ_skill2_1_Model)

function M:spawnFinish()
    M.super.spawnFinish(self)
end

---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    if attackData.skillConfig and  attackData.skillConfig.anim_name == self.skill.anim_name then
        if self:getResLevel() >= self.damageAddLevel then
            attackData["damageLast"] = attackData["damageLast"] + self.afterDamageAddValue
        end
    end
end

return M