--鬼谷 skill3被动
--鬼谷引动天雷，对所有敌人造成300%攻击力的伤害，
--若命中的敌人被添加了诛邪印机，则会额外造成一次伤害
--被添加了诛邪印机的敌人还会额外收到持续2秒的眩晕
local W_GuiG_skill3_1_View = require("BattleView.Ply.SkillFeatures.W_GuiG_skill3_1_View")
---@class W_GuiG_skill3_3 : W_GuiG_skill3_1_View @
---@field super W_GuiG_skill3_1_View @W_GuiG_skill3_1_View
local M = class("W_GuiG_skill3_3", W_GuiG_skill3_1_View)

return M