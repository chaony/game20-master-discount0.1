--少林skill2 少林进入防御状态 5秒 期间无法攻击和移动且会免疫所有控制效果，
--防御状态下回获得一个护盾，抵消自升攻击里500%的伤害，
--若该护盾在持续期间被打破，则少林会获得30%的减伤持续到防御状态结束
---@class W_ShaoL_skill2_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_ShaoL_skill2_View", SkillFeatures_View)

return M