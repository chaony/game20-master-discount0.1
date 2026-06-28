--太极身周围会环绕一个阴阳球，每当太极释放普攻时，若身边存在阴阳球，则太极会将阴阳球扔至随机敌方脚下，对小范围内的敌人造成180%攻击力的内功伤害，扔出的阴阳球会在战场上停留3秒，之后再返回太极身边
---@class W_TaiJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiJ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.ballCount = 1
end

return M