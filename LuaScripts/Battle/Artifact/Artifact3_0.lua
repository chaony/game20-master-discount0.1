
--希望号角 每秒获得10点能量
---@class Artifact3_0 : Artifact @
---@field super Artifact @Artifact
local M = class("Artifact3_0", Artifact)

--获得能量
M.energy = 10

function M:init(player,data)
    M.super.init(self, player, data)
    self.energy = self:getValue(1)
end


function M:gameStart()
    M.super.gameStart(self)
    self.player.data.restore_anger:addToAddList(self.energy) 
end



return M