--丐帮身上的每层“酒意”buff，都会为其提供12%的伤害减免以及10%的攻速提升。
--当“酒意”buff叠满时，丐帮会进入“醉倒”状态5秒，“醉倒”状态下，丐帮无法
--攻击也无法移动。“醉倒”状态结束后，会清除身上所有“酒意”buff。
---@class W_GaiB_skill0_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_GaiB_skill0_1_View", SkillFeatures_View)

return M