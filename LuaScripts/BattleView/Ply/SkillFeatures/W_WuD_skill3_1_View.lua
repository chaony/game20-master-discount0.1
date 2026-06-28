-- 释放成功后，立即为所有敌方施加一层中毒，并每秒对所有敌人造成70%攻击力伤害，持续12秒技能结束时，将持续期间造成总伤害的50%转化为对自身的血量（中毒：每2秒发作一次，发作时造成100%攻击力的伤害并减少中毒者3点内力，持续6秒，最多叠加5层）
---@class W_WuD_skill3_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_WuD_skill3_1_View", SkillFeatures_View)


return M