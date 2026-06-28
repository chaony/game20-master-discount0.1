--当嵩山的生命值低于30%时，会立即使用寒冰真气冰封自身4秒，
--期间无法攻击也不会受到任何伤害，并每秒恢复最大生命值的15%，
--每场战斗仅可触发1次。
---@class W_SongS_skill0_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_SongS_skill0_1_View", SkillFeatures_View)

return M