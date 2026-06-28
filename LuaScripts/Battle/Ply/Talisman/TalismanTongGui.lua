--- 同归
--- 被攻击时，有20%的几率让对方受到自身攻击力50%的伤害
---@class TalismanTongGui : Talisman
---@field super Talisman
local M = class("TalismanTongGui", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.radomValue = self:getParam(1); --几率
    self.buffId = self:getParam(2); --反伤
end

function M:BeHit(attackData)
    if GlobalTools:CheckRandom1(self.radomValue) then
        attackData.victim.bufMgr:addBufById(self.buffId, self.player)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;