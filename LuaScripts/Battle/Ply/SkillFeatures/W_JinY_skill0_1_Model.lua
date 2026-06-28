---@class W_JinY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinY_skill0_1_Model", SkillFeatures_Model)

--伤害提高百分比
M.atk = nil
--额外伤害百分比
M.additionalAtk = nil

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.atk = self:getParam(1)
    self.atk_value = self.atk
    self.additionalAtk = self:getParam(2)
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
    if skill ~= nil and skill.anim_name == "attack1" then
        self.atk_value = self.atk
        if self.additionalAtk > 0 then
            local debuff = victim.bufMgr:findBufByTag("debuff")
            if  table.nums(debuff) > 0 then
                self.atk_value= self.atk_value + self.additionalAtk
            end
        end
        self.player.data.physicaldamage:addToMulListTemp(self.atk_value)
        self.player.data.magicdamage:addToMulListTemp(self.atk_value)
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M