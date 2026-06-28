--龙门 攻击异常状态下的敌人时，造成的伤害提升20%
---@class W_LongM_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LongM_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dmg = self:getParam(1)
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local damage = data["damage"]
    local injureType = data.attackData.injureType
    
    if killer ~= nil and killer:equal(self.player) then
        if victim ~= nil and injureType ~= "dot" then
            local debuff = victim.bufMgr:findBufByTag("liuxue")
            if table.nums(debuff) > 0  then
                local damage_value = GlobalTools:Mul(self.dmg, data.damage);
                data.damage = data.damage + damage_value
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end


return M