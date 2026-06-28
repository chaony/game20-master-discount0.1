--绝情 skill1 对前面的敌人进行三段连击 每段90%攻击力的伤害 最后一击为敌人施加1层绝杀印记 印记最多叠加5层 每层都会使该技能的伤害提高10%
---@class W_JueQ_skill1_1_Model : SkillFeatures_Model
local M = class("W_JueQ_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dmg = self:getParam(1)
    self.dmg_value = self.dmg
    self.start = false
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local damage = data["damage"]
    local skill = data.attackData.skillConfig
    self.dmg_value = self.dmg
    if killer ~= nil and killer:equal(self.player) and skill ~= nil and skill.anim_name == "skill1" then
        if victim ~= nil then
            local marks = victim.bufMgr:findBufByTag("pojia")
            local count = GlobalTools:ToFix(#marks)
            local dmg_count = GlobalTools:Mul(self.dmg_value, count);
            local damage_value = GlobalTools:Mul(data.damage, dmg_count);
            data.damage = data.damage + damage_value
            return data.damage
        end
    end
    return data.damage
end



function M:destroy()
    M.super.destroy(self)
end

return M