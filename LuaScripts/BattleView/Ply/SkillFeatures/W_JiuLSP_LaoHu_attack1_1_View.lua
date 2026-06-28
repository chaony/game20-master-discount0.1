--九黎虎
---@class W_JiuLSP_LaoHu_attack1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JiuLSP_LaoHu_attack1_1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
end

function M:loadFinish(data)
    if IsNull(self.player.body) == false then
        self.player.body.gameObject:SetActive(false)
        self.player:ShowHpBar(false)
    end
end

return M