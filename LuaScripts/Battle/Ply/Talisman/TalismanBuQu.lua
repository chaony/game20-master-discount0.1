--- 不屈
--- 被攻击时，有30%概率让对方停止回怒2秒
---@class TalismanBuQu : Talisman
---@field super Talisman
local M = class("TalismanBuQu", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.radomValue = self:getParam(1); --30%概率
    self.buffId = self:getParam(2); --
end

function M:BeHit(attackData)
    local killer = attackData["killer"]
    local victim = attackData["victim"]
    if self.player:equal(victim) and self.player.camp ~= killer.camp then
        if GlobalTools:CheckRandom1(self.radomValue) then
            attackData.killer.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;