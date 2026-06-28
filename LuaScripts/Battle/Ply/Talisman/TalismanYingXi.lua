--- 影袭
--- 每次普攻有30%概率，暴击率增加5%、暴伤提升5%的效果，最多叠加5层
---@class TalismanYingXi : Talisman
---@field super Talisman
local M = class("TalismanYingXi", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.radomValue = self:getParam(1); --概率
    self.buffId = self:getParam(2); --暴击暴伤
end

function M:Attack( attackData )
    local skillConfig = attackData.attackData.skillConfig
    if skillConfig and skillConfig.anim_name == "attack1" then
        if GlobalTools:CheckRandom1(self.radomValue) then
            self.player.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end

return M;