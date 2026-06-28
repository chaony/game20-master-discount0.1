--九黎猫
---@class W_JiuL1_attack1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JiuL1_attack1_1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
end

function M:loadFinish(data)
    self.player:ShowHpBar(false)
end

return M