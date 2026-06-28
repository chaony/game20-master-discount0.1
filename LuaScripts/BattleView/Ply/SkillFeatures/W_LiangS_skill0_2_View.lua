--梁山 每场战斗一次，当梁山受到致命伤害时，会免疫本次伤害并立即进入“浴血”状态，进入“浴血”状态时
--梁山会立即回满生命值。“浴血”状态持续期间，梁山会获得25点吸血等级，但每秒会损失最大生命值的10%
--“浴血”状态持续期间，梁山的攻击力每秒提升10%，最高提升100%
local W_LiangS_skill0_1_View = require("BattleView.Ply.SkillFeatures.W_LiangS_skill0_1_View")
---@class W_LiangS_skill0_2_View : W_LiangS_skill0_1_View @
---@field super W_LiangS_skill0_1_View @W_LiangS_skill0_1_View
local M = class("W_LiangS_skill0_2_View", W_LiangS_skill0_1_View)

return M