--角色的专属装备
--华山
--战斗中，华山会获得70点闪避
---@class W_HuaS_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_HuaS_Trait0", PlayerTrait)


M.buff = 0

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