--- 烈风
--- 每次攻击有30%概率让对方，减伤效果降低30%
---@class TalismanLieFeng : Talisman
---@field super Talisman
local M = class("TalismanLieFeng", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.radomValue = self:getParam(1); --概率
    self.buffId = self:getParam(2); --暴击暴伤
end

function M:Attack( attackData )
    local skillConfig = attackData.attackData.skillConfig
    if skillConfig then
        if GlobalTools:CheckRandom1(self.radomValue) then
            attackData.victim.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end

return M;