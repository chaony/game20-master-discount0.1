--角色的专属装备
--白驼 战斗中白驼受到的生命恢复效果提升20%

---@class W_BaiT_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_BaiT_Trait0", PlayerTrait)

M.buffId = 0

function M:init()
    M.super.init(self) 
    self.buffId = self:getValue(1)  --生命恢复效果
end

function M:spawn()
    M.super.spawn(self)
    self.player.bufMgr:addBufById(self.buffId,self.player)
end




function M:destroy()

    M.super.destroy(self)

end

return M