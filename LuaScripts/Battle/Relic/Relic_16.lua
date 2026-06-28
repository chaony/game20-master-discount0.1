--怒气护腕
--受伤回怒+40%
---@class Relic_16 : Relic @
---@field super Relic @Relic
local M = class("Relic_16", Relic)

--命中
M.hurtrageregen = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.hurtrageregen = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithData(ply, "hurtrageregen", 1)
	end
end

return M