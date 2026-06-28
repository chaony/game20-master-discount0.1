--蹶张在连续攻击同一个目标时，会逐渐提升自身攻速。每重复攻击一次，
--便获得一层攻速提升效果，最多叠加10层。每层效果会提升自身10%攻速。
--该效果会在更换目标时重置
---@class W_JueZ_skill1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JueZ_skill1_1_View", SkillFeatures_View)

return M