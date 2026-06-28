--角色的专属装备
--霹雳 火焰护甲的爆炸不再有次数限制，但会有0.5秒的冷却时间
---@class W_PiL_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_PiL_Trait0", PlayerTrait)

M.maxTime = 0
M.skillImprove = 0

function M:init()
    M.super.init(self) 
    self.maxTime = self:getValue(1)  --冷却时间
    self.skillImprove = self:getValue(2)  -- 火焰护甲
end

function M:spawn()
    M.super.spawn(self)
 	self.player.skillImprove:addItem("equip_hero",self.skillImprove)
end


function M:destroy()

    M.super.destroy(self)
end

return M