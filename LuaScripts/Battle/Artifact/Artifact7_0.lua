
--永恒圣杯 战斗开始后的30秒内，每秒回复生命上限的1%生命


---@class Artifact7_0 : Artifact @
---@field super Artifact @Artifact
local M = class("Artifact7_0", Artifact)

M.hp = nil

M.time = nil

M.curTime = nil

M.lastTime = nil

function M:init(player,data)
    M.super.init(self, player, data)
    self.time = self:getValue(1)
    self.hp = self:getValue(2)
end

function M:gameStart()
    M.super.gameStart(self)
    self.curTime = self.time
    self.lastTime = self.curTime
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)    
    if self.curTime >0 then
        self.curTime = self.curTime - dt
        if self.curTime <= 0 then
            self.curTime = 0
        end
        if self.lastTime ~= self.curTime then
            self.player:cure("hp", self.player, self.hp)
        end
    end
end

return M