--- 突围
--- 攻击血量高于70%的目标，伤害增加10%
--- 攻击血量高于60%的目标，伤害增加15%
--- 攻击血量高于50%的目标，伤害增加20%
---@class TalismanTuWei : Talisman
---@field super Talisman
local M = class("TalismanTuWei", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.hpRate = self:getParam(1); --目标血量
    self.damageAdd = self:getParam(2);--伤害增加
end

function M:Attack( attackData, wantdata )
    if self.hpRate > 0 and self.damageAdd > 0 then 
        if attackData.victim ~= nil then
            if attackData.victim.data:get_hpRate() > self.hpRate then
                --伤害+10%
                wantdata["damage"] = wantdata["damage"] + GlobalTools:Mul(wantdata["damage"], self.damageAdd)
            end
        end 
    end
end

return M;