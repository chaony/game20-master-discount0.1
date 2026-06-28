--角色的专属装备
--华山
--战斗中，华山会获得70点闪避
--华山会获得90点闪避

--华山每拥有100点闪避，受到的内功型伤害就减少20%
local W_HuaS_Trait1 = require("Battle.Ply.Trait.W_HuaS_Trait1")
---@class W_HuaS_Trait2 : W_HuaS_Trait1 @
---@field super W_HuaS_Trait1 @W_HuaS_Trait1
local M = class("W_HuaS_Trait2", W_HuaS_Trait1)

M.resValue = 0

function M:init()
    M.super.init(self)
    self.resValue = self:getValue(2)
   
end

--作为攻击者的属性临时调整
function M:victimDataChangeTemp(killer)
	M.super.victimDataChangeTemp(self,killer)
	local count = math.floor(self.player.data.dodge:getValue() / 100)
	if count > 0 then
		self.player.data.res:addToMulListTemp(count * self.resValue)
	end
		
	
end




function M:destroy()
    M.super.destroy(self)
end
return M