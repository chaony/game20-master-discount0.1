
--圣灵披风 战斗中的生命回复效果加10%

---@class Artifact4_0 : Artifact @
---@field super Artifact @Artifact
local M = class("Artifact4_0", Artifact)

M.sethp = nil

function M:init(player,data)
    M.super.init(self, player, data)
    self.sethp = self:getValue(1)
end


function M:gameStart()
    M.super.gameStart(self)
    
    self.player.data.hpRecover:addToMulList( self.sethp)
    
end



return M