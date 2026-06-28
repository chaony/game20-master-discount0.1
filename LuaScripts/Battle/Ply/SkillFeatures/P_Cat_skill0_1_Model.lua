--释放绝技后，有50%概率进入状态，效果为：下次释放绝技时，额外增加恢复效果250%攻击力的血量
---@class P_Cat_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Cat_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffRate = self:getParam(1) -- 进入状态的概率
    self.buffData = self:getParam(2) -- 加血buff
end

function M:destroy()
    M.super.destroy(self)
end

return M