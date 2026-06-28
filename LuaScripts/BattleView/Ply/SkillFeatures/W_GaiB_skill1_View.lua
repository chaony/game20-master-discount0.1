--丐帮锁定自身攻击范围内最虚弱的敌人，将其甩到自己背后，
--造成200%攻击力的外功伤害，并使其攻击力减少30%，持续5秒。
--若该敌人落地的位置上有其他敌方角色，则会使命中的所有敌方角色眩晕2秒。
---@class W_GaiB_skill1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_GaiB_skill1_View", SkillFeatures_View)

return M