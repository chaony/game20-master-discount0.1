--角色的专属装备
--探花 探花的普工 会无视敌方70%的防御
---@class W_TanH_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_TanH_Trait0", PlayerTrait)

M.def_value = 0

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.def_value = self:getValue(1)

end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim)
	if self.player.curSkillConfig ~= nil and self.player.curSkillConfig.anim_name == "attack1" then
		if victim ~= nil and victim.camp ~= self.player.camp then
			local value = (victim.data.def:getValue() * self.def_value) * -1
			victim.data.def:addToAddListTemp( value )
		end
	end
end





function M:destroy()
    M.super.destroy(self)
end

return M