--淬炼之甲
--获得遗物后，每获得一场胜利己方英雄防御+3%，最多增加12%
---@class Relic_21 : Relic @
---@field super Relic @Relic
local M = class("Relic_21", Relic)

--防御增加量
M.def = nil
--最大增加量
M.maxDef = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.def,self.calType = self:getValue(1)
	self.maxDef = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	--获胜场次
	local winCount = self.param["win"] or 0
	local value = GlobalTools:Mul(self.def, GlobalTools:ToFix(winCount))
	if value > self.maxDef then
		value = self.maxDef
	end
	
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithValue(ply, "def", self.calType, value)
	end
end

return M