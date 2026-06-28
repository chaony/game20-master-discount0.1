--龙门 攻击中毒状态下的敌人 该技能的伤害增加30%
---@class W_LongM_skill3_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LongM_skill3_3_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dmg = self:getParam(1)
end


--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local damage = data["damage"]
    local skill = data.attackData["skillConfig"]
    if killer ~= nil and killer:equal(self.player) and skill ~= nil and skill.anim_name == "skill3" then
        if victim ~= nil then
            local debuff = victim.bufMgr:findBufByTag("liuxue")
            if table.nums(debuff) > 0  then
                local damage_value = GlobalTools:Mul(self.dmg, data.damage);
                data.damage = data.damage + damage_value
            end
        end
    end
    return damage
end


return M