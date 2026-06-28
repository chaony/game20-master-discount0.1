---@class W_XingY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XingY_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.dmg = self:getParam(1)
    self.dmgLimit = self:getParam(2)    -- Fix[0-1000]对boss的最大伤害限制：xx倍攻击力
end


function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data.victim;
    local skillConfig = data.attackData["skillConfig"]
    local injureType = data.attackData["injureType"]
    if killer ~= nil and killer:equal(self.player) and skillConfig ~= nil and skillConfig.anim_name == "skill0" and injureType ~= "dot" then
        local hp_dmg = GlobalTools:Mul( victim.data:get_curHp(), self.dmg )

        -- 不可以造成负数伤害
        if hp_dmg < GlobalTools.base1 then
            hp_dmg = GlobalTools.base1
        end
        
        data.damage = data.damage + hp_dmg
        
        if victim.isBoss and self.dmgLimit > 0 then   -- 对boss有最大伤害限制
            local limit = GlobalTools:Mul(self.player.data.atk:getValue(), self.dmgLimit)
            data.damage = Mathf.Min(data.damage, limit)
        end
    end 
end

function M:destroy()
    M.super.destroy(self)
end

return M