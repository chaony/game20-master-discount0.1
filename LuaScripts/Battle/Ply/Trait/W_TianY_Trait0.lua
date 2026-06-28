--角色的专属装备
--天鹰 战斗中天鹰命中增加60点
---@class W_TianY_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_TianY_Trait0", PlayerTrait)


M.buff = nil
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