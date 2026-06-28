--- 威赫
--- 自身血量低于50%时，每次攻击有30%几率强制对手攻击自己
---@class TalismanWeiHe : Talisman
---@field super Talisman
local M = class("TalismanAoXue", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.hpRate = self:getParam(1); --血量
    self.tauntRate = self:getParam(2); --嘲讽几率
    self.tauntBuffId = self:getParam(3); --嘲讽几率buff
end

function M:Attack( attackData )
    local curHpRate = self.player.data:get_hpRate()
    local skillConfig = attackData.attackData.skillConfig
    if skillConfig and curHpRate < self.hpRate then
        if GlobalTools:CheckRandom1(self.tauntRate) then
            attackData.victim.bufMgr:addBufById(self.tauntBuffId, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;