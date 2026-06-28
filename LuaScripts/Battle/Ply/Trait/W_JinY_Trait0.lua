--角色的专属装备
--锦衣 战斗中锦衣会获得20%的攻击提升
---@class W_JinY_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_JinY_Trait0", PlayerTrait)


M.atk = 0
function M:init()
    M.super.init(self)
    self.buff = self:getValue(1)
  
end

function M:spawn()
    M.super.spawn(self)

    self.player.bufMgr:addBufById(self.buff,self.player)
end




function M:destroy()
    M.super.destroy(self)
end

return M