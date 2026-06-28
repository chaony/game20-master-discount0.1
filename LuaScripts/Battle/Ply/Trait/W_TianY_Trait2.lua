--角色的专属装备
--天鹰 战斗中天鹰命中增加60点

--战斗中天鹰命中增加80点
--天鹰在攻击敌人的时候，若自己的命中值大于敌人的闪避值，则没点溢出的命中会提升0.2%的伤害，做多提升20%的伤害
local W_TianY_Trait1 = require("Battle.Ply.Trait.W_TianY_Trait1")
---@class W_TianY_Trait2 : W_TianY_Trait1 @
---@field super W_TianY_Trait1 @W_TianY_Trait1
local M = class("W_TianY_Trait2", W_TianY_Trait1)

--最大提升值
M.maxvalue = nil
--每点加的伤害值
M.atk = nil
function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)
    self.maxvalue = self:getValue(2)
  
end
--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim)
	if victim ~= nil then
        local dodge = victim.data.dodge:getValue()
        if self.player.data.hr:getValue() > dodge then
        	local value = self.player.data.hr:getValue() - dodge
        	local addDmg = value * self.atk
        	if addDmg > self.maxvalue then 
        		addDmg = self.maxvalue
        	end
        	self.player.data.atk:addToMulListTemp(addDmg)
        end
    end
end



function M:destroy()
    M.super.destroy(self)
end

return M