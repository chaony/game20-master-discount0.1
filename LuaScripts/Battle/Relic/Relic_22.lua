--淬炼之甲
--获得遗物后，每获得一场胜利己方英雄攻击+3%，最多增加12%
---@class Relic_22 : Relic @
---@field super Relic @Relic
local M = class("Relic_22", Relic)

--攻击增加量
M.atk = nil
--最大增加量
M.maxAtk = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.atk =self:getValue(1)
	self.maxAtk = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	--获胜场次
	local winCount = self.param["win"] or 0
	local value = GlobalTools:Mul(self.atk, GlobalTools:ToFix(winCount))
	if value > self.maxAtk then
		value = self.maxAtk
	end
	
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithValue(ply, "atk", self.calType, value)
	end
end

return M