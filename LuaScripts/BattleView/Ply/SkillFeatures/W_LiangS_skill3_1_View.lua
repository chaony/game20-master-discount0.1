--梁山挥舞双斧，一边旋转一边在敌人之间移动，期间每秒消耗100
--点内力并对周围的敌人造成150%攻击力的伤害。
--旋转期间梁山免疫控制效果，该状态会一直持续到梁山死亡或内力耗尽
---@class W_LiangS_skill3_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_LiangS_skill3_1_View", SkillFeatures_View)

return M