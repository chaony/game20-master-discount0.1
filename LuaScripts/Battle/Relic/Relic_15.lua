--倒刺匕首
--本方全体武魂+40%暴击伤害
---@class Relic_15 : Relic @
---@field super Relic @Relic
local M = class("Relic_15", Relic)

--命中
M.crit = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.crit = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithData(ply, "crit", 1)
	end
end

return M