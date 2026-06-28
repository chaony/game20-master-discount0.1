
--单体伤害增加
---@class BufWorkSingleDamageAdd : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkSingleDamageAdd", BufWork_Model)

function M:initFinish()
	self.atk = self.playerBuf:checkParam("atk", 0)
end

--作为攻击者的属性临时调整
function M:victimDataChangeTemp(killer)
	M.super.victimDataChangeTemp(self, killer)
	if killer ~= nil and killer:equal(self.playerBuf.source) then
		killer.data.physicaldamage:addToMAAListTemp(self.atk, "buff")
		killer.data.magicdamage:addToMAAListTemp(self.atk, "buff")
	end
end

return M