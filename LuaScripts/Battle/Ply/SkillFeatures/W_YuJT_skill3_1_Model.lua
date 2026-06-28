--御竞堂向敌方最密集区域踢出蹴鞠，蹴鞠落地后会爆炸，对大范围内的敌人造成300%攻击力的伤害和2秒眩晕效果
--lv2命中敌人身上每有一层“破甲”状态，该技能造成的伤害就会提升10%
---@class W_YuJT_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill0 W_YuJT_skill0_1_Model
local M = class("W_YuJT_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hurtAddRate = self:getParam(1) --伤害就会提升10%
end


--攻击者攻击开始处理
---@param data Battle_HandleData_Attack
function M:killerBeforeAttack(data, victim)
    if self.player:equal(data.player) and data.skillConfig == self.skill then
        local buffs = victim.bufMgr:findBufByTag("pojia") -- 破甲层数
        if #buffs>0 then
            local origin_damage = data["damage"]
            local add_damage = 0
            for i = 1, #buffs do
                add_damage = add_damage + GlobalTools:Mul(origin_damage, self.hurtAddRate)
            end
            data["damage"] = data["damage"] + add_damage
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M