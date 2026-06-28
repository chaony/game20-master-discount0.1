--角色的专属装备
--太极 太极现在回拥有两个阴阳球,伤害降为60%

---@class W_TaiJ_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_TaiJ_Trait0", PlayerTrait)

M.hp = 0
M.start = false


function M:init()
    M.super.init(self)
	self.equip_hero_id = self:getValue(1)
end

function M:spawn()
    M.super.spawn(self)
	local skill3 = self.player.plySkill:getSkillByName("skill3")
	if skill3 ~= nil then
		self.skill3 = skill3.cur_skill_config.feature
		if self.skill3 ~= nil then
			self.skill3.ballCount = 2
		end
	end
	self.player.skillImprove:addItem("equip_hero",self.equip_hero_id)
end

function M:destroy()
	self.player.skillImprove:removeItem("equip_hero",self.equip_hero_id)
	M.super.destroy(self)
end

return M