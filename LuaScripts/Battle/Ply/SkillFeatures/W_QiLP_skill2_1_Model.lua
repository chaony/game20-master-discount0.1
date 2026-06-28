--非骑射状态下，射一箭，对其造成200%攻击力的伤害并附加一层流血效果；骑射状态下，启灵派会在猎豹扑咬敌人后再对其射一箭，额外造成200%攻击力的伤害和一层流血效果

---@class W_QiLP_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiLP_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.skill2Flag = self:getParam(1) -- 每次进入骑射状态下立即释放skill2 [0 不释放，1立即释放]
end

function M:destroy()
    M.super.destroy(self)
end

return M