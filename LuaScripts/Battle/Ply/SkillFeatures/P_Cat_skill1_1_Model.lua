--受到治疗的宠物单位，该局获得持续全局的（伤害加深，暴击， 3选一 看着给）随机增益效果1%，增益效果最多叠加3层
---@class P_Cat_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Cat_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData1 = self:getParam(1) -- 暴击
    self.buffData2 = self:getParam(2) -- 攻击
    self.buffData3 = self:getParam(3) -- 伤害加深
end

function M:destroy()
    M.super.destroy(self)
end

return M