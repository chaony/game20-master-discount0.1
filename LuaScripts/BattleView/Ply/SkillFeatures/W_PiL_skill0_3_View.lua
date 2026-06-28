--霹雳在受到致命伤害时，会冲到距离自己最近的一名敌人面前并自爆，
--对爆炸范围内的敌人造成600%攻击力的伤害
--若该技能击杀了敌人，则被击杀的敌人也会爆炸，额外造成一次伤害。
local W_PiL_skill0_1_View = require("BattleView.Ply.SkillFeatures.W_PiL_skill0_1_View")
---@class W_PiL_skill0_3_View : W_PiL_skill0_1_View @
---@field super W_PiL_skill0_1_View @W_PiL_skill0_1_View
local M = class("W_PiL_skill0_3_View", W_PiL_skill0_1_View)

return M