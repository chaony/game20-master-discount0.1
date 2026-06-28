--角色的专属装备
--丐帮 “酒意”buff的最大叠加层数提升至6层

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
	self.player.skillImprove:addItem("equip_hero",self.equip_hero_id)
end

function M:destroy()
	self.player.skillImprove:removeItem("equip_hero",self.equip_hero_id)
	M.super.destroy(self)
end

return M