-- 战斗中，每当蜀山的攻击造成暴击时，便为自身施加一层持续15秒的“凌羽”效果，每层翎羽效果会提升蜀山5%攻击速度，最多叠加10层

---@class W_ShuS_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShuS_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.addBuff1 = self:getParam(1)    -- Buff[] -- 凌羽buff
end

---@param afterAttackData Battle_HandleData_Attack
function M:killerAfterAttack(afterAttackData)
    if afterAttackData.isCrit then
        self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    end
end

return M