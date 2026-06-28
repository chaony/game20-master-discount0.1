--绝情 skill1 对前面的敌人进行三段连击 每段90%攻击力的伤害 
--最后一击为敌人施加1层绝杀印记 印记最多叠加5层 每层都会使该
--技能的伤害提高10%
--普通攻击暴击时，立即释放一次该技能
local W_JueQ_skill1_1_View = require("BattleView.Ply.SkillFeatures.W_JueQ_skill1_1_View")
---@class W_JueQ_skill1_3_View : W_JueQ_skill1_1_View @
---@field super W_JueQ_skill1_1_View @W_JueQ_skill1_1_View
local M = class("W_JueQ_skill1_3_View", W_JueQ_skill1_1_View)

return M