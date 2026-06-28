---乘风
---每次攻击有，50%概率给目标减5%暴击，持续3秒，最多叠加5层
---@class TalismanChengFeng : Talisman
---@field super Talisman
local M = class("TalismanChengFeng", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.radomValue = self:getParam(1); --概率
    self.buffId = self:getParam(2); --
end

function M:Attack( attackData )
    local skillConfig = attackData.attackData.skillConfig
    if skillConfig then
        if GlobalTools:CheckRandom1(self.radomValue) then
            attackData.victim.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;