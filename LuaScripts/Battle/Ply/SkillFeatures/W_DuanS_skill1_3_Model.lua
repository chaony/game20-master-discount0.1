--段氏skill2等级二被动
--该技能造成伤害的35%转换为自身的血量
---@class W_DuanS_skill1_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuanS_skill1_3_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --百分比
	self.cure = self:getParam(1)
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    M.super.killerAfterAttack(self, data)
    local skill = data.attackData.skillConfig
    if skill ~= nil and skill == self.skill then
        local damage = data.damage
        local damage_value = GlobalTools:Mul(damage, self.cure);
        self.player:cure("fix", self.player, damage_value, self.skill)
    end
end
   

return M