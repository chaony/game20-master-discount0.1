-- 被剑羽攻击的 敌人会留下一个印记,被飞天状态下的蜀山攻击则 引爆印记,每个印记造成50%攻击力的伤害

local W_ShuS_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_ShuS_skill2_1_Model")

---@class W_ShuS_skill2_2_Model : W_ShuS_skill2_1_Model @
---@field super W_ShuS_skill2_1_Model @W_ShuS_skill2_1_Model
---@field skill3 W_ShuS_skill3_1_Model
local M = class("W_ShuS_skill2_2_Model", W_ShuS_skill2_1_Model)

M.myStampBuffTag = "W_ShuS_skill2"

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end


---@param afterAttackData Battle_HandleData_Attack
function M:killerAfterAttack(afterAttackData)
    M.super.killerAfterAttack(self, afterAttackData)

    if self:isInAir() and afterAttackData.victim then
        local buffs = afterAttackData.victim.bufMgr:findBufByTag(M.myStampBuffTag)
        if #buffs > 1 then
            afterAttackData.victim.bufMgr:removeBufByTag(M.myStampBuffTag, true)
            for i = 1, #buffs do
                afterAttackData.victim.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
            end
        end
    end
end

function M:isInAir()
    if not self.skill3 then
        local skill3 = self.player.plySkill:getSkillByName("skill3")
        if skill3 and skill3.cur_skill_config then
            self.skill3 = skill3.cur_skill_config.feature
        end
    end
    return self.skill3 and self.skill3:isInAir()
end

return M