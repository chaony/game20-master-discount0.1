--阿驼每释放一次绝技，己方全体奇兽立刻回复内力200点
---@class P_YangT_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_YangT_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData = self:getParam(1) -- 回复内力
end

function M:destroy()
    M.super.destroy(self)
end

return M