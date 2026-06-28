--角色的专属装备
--段式 战斗中段式获得20%的攻击提升
---@class W_DuanS_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_DuanS_Trait0", PlayerTrait)

function M:init()
    M.super.init(self)
    self.buff = self:getValue(1)  
end

function M:spawn()
    M.super.spawn(self)
    self.player.bufMgr:addBufById(self.buff, self.player)
end

function M:destroy()
    M.super.destroy(self)
end

return M