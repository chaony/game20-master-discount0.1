--探花为自己的飞刀附加强化效果，使下一次普攻的暴击率提升100%，且无视敌方护盾。该技能可在普攻蓄力期间释放，且不会打断蓄力。
---@class W_TanH_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TanH_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.critrate = self:getParam(1)
    self.dmg = self:getParam(2)
    self.isImprove = false;
    self.armorBreak = false
end

function M:spawn()
    M.super.spawn(self)
end

function M:canUse()
    if self.isImprove == true then  -- 已经有强化效果，那么不再强化
        return false
    end
    return M.super.canUse(self)
end

--技能释放
function M:skillStart(data)
    M.super.skillStart(self, data)
    self.isImprove = true
end

--使用了强化
function M:use()
    self.isImprove = false
end

return M