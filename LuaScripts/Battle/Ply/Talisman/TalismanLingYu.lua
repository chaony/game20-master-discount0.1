--- 領域
--- 绝技技能伤害增加10%，如是范围技能，伤害增加15%
---@class TalismanLingYu : Talisman
---@field super Talisman
local M = class("TalismanLingYu", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.addRate1 = self:getParam(1); --技能伤害增加10%
    self.addRate2 = self:getParam(2); --技能伤害增加15%
end

function M:Attack( attackData, wantdata )
    local skillConfig = attackData.attackData.skillConfig
    if skillConfig and skillConfig.type and skillConfig.type == 1 then
        if skillConfig.is_aoe then
            wantdata["damage"] = wantdata["damage"] + GlobalTools:Mul(wantdata["damage"], self.addRate2)
        else
            wantdata["damage"] = wantdata["damage"] + GlobalTools:Mul(wantdata["damage"], self.addRate1)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M;