
--神圣之刃 战斗开始每3秒增加1%攻击力

---@class Artifact5_0 : Artifact @
---@field super Artifact @Artifact
local M = class("Artifact5_0", Artifact)

M.atk = nil

M.time = nil

M.curTime = nil

function M:init(player,data)
    M.super.init(self, player, data)
    self.atk = self:getValue(2)
    self.time = self:getValue(1)
    
end

function M:gameStart()
    M.super.gameStart(self)
    self.curTime = self.time
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    
    if self.curTime > 0 then
        self.curTime = self.curTime - dt
        if self.curTime <= 0 then
            self:addData()
            self.curTime = self.time
        end
    end
end

function M:addData()
   self.player.data.atk:addToMulList(self.atk) 
end

return M