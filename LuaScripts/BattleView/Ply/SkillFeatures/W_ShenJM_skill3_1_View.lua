---@class W_ShenJM_skill3_1_View : SkillFeatures_View
---@field super SkillFeatures_View
local M = class("W_ShenJM_skill3_1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
end

function M:spawn()
    M.super.spawn(self)
    if IsNull(self.player.tranformHelper) == false and IsNull(self.player.tran) == false then
        self.weapon1_1 = self.player.tranformHelper:FindObj(self.player.tran, "W_ShenJM_Weapon2")
        self.weapon1_2 = self.player.tranformHelper:FindObj(self.player.tran, "W_ShenJM_Weapon3")
        self.weapon1_1:SetActive(false)
        self.weapon1_2:SetActive(false)
    end
end

return M
