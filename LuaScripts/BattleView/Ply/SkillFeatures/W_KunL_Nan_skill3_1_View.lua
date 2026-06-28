---@class W_KunL_Nan_skill3_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_KunL_Nan_skill3_1_View", SkillFeatures_View)

--技能结束时
function M:skillEnd(data)
    self.player.bufMgr:setEffectHide(false)
end

--技能开始时
function M:skillStart(data)
    self.player.bufMgr:setEffectHide(true)
end

return M