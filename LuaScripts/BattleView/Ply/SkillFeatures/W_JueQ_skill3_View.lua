--绝情 skill3 控制飞刀攻击敌方“绝杀印”最多的英雄，造成300%的攻
--击力的伤害并给对方施加一层绝杀印
--当释放目标有3层以上的绝杀印时还会使敌人沉默3秒 当释放目标有
--5层绝杀印时，清除敌人的绝杀印并使本技能的伤害提升300%
---@class W_JueQ_skill3_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JueQ_skill3_View", SkillFeatures_View)

return M