--每释放一次大招，获得持续全场的自身攻速提升X%
--斗气胜利时，额外提升X点
---@class P_Niao_skill4_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Niao_skill4_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData1 = self:getParam(1) -- 自身攻速提升X%
    self.buffData2 = self:getParam(2) -- 斗气胜利自身攻速提升X%
end

function M:destroy()
    M.super.destroy(self)
end

return M